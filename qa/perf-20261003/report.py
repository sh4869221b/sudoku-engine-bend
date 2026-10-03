#!/usr/bin/env python3
import hashlib,json,pathlib,subprocess
root=pathlib.Path(__file__).resolve().parents[2];out=root/'qa/perf-20261003'
ledger=sorted(json.loads((out/'results/ledger.json').read_text()),key=lambda x:x['number'])
assert len(ledger)==10 and all(x['status']=='TESTED' for x in ledger)
aggregate=json.loads((out/'final-aggregate.json').read_text());measurement=json.loads((out/'final-measurement.json').read_text());diff=json.loads((out/'final-differential.json').read_text());assert diff['status']=='PASS'
verifylog=(out/'final-verify.log').read_text();assert 'Verification PASS:' in verifylog
verifydir=pathlib.Path(verifylog.strip().split('Verification PASS: ')[-1]);summary=json.loads((verifydir/'summary.json').read_text());assert summary['status']=='PASS';(out/'final-verification-summary.json').write_text(json.dumps(summary,indent=2)+'\n')
for name in ['empty-search-state.json','benchmark.json','cli-results.json','lanes.json']:
 p=verifydir/'work/.omo/evidence'/name
 if p.exists():(out/('final-'+name)).write_bytes(p.read_bytes())
base=root.parent/'baseline';candidate=root/'bin/bend-sudoku';assert hashlib.sha256(base.read_bytes()).digest()==hashlib.sha256(candidate.read_bytes()).digest()
reasons=['初期化の走査削減は総合性能に再現可能な利益なし','表引きが総合性能を悪化させた。再試行でも0.842倍','最下位ビットの表引きは改善なし','単位ごとの分岐化は改善なし','最初の不正理由で検証を止めても固定全体では改善なし','文字範囲判定の削減は改善なし','逆順累積で表示しても改善なし','余分な配列読み取り削除は約0.8%で採用閾値未満','単一候補の高速判定は改善なし','空欄更新の専用経路は約0.6%で採用閾値未満']
text=f'''# Bend Sudoku 高速化実験 — 2026-10-03

## 結果

**異なる10案を実装し、正しさと性能を測定して停止。採用0案。5倍未達成。**
採用基準を満たさない変更はすべて元へ戻した。最終のエンジンソース、既存QA、
固定入力、燃料、出力仕様、LAWS/PROOF、ビルド設定は開始時と同一。
基準と最終実行ファイルもSHA256で一致しているため、実装上の累積速度比は1.000倍。

開始: `343bf98cd6d2b128882bc4dcd8300df0cd2b55c6`。
作業ブランチ: `perf/optimization-loop`。
対象は新規に取得した `sh4869221b/sudoku-engine-bend`。
旧アーカイブのリポジトリ、既存の未コミット作業には変更していない。
リモート公開・push・mergeなし。関連AGENTS.mdと .agents/skills はこのcheckoutおよび
親階層に存在せず、sessionsも読んでいない。

## 先に決めた評価方法

[PROTOCOL.md](PROTOCOL.md)を最初のタイミング測定前に保存。
主指標は変更しない35ケース（7コマンド、1/8/16スレッド）の壁時計時間中央値の合計。
基準合計/最終合計が5以上を目標とした。速いケースの選別はしていない。
候補screenは固定7件の実用的な1スレッド処理、2ウォームアップ+9反復。
最終は固定35件すべて、2ウォームアップ+21反復。プロセスを1つずつ起動し、
乱数seed固定で基準/候補の実行順を変え、出力・終了値・stderrを比較。
BENCHのみタイマーの数値を正規化。内部タイマーは主指標ではない。

採用はscreenの合計3%以上、影響を受ける実用ケース5%以上の改善を要し、
候補がそれを満たせば35ケースの21反復確認、bootstrap信頼区間、退行確認を行う
方針だった。どのscreenも3%に達せず、採用候補の確認段階へ進む案はなかった。
最終再測定と全テストは採用0でも省略していない。

ホスト: `{measurement['metadata']['cpu']}` / cachyos-x8664。
Bend 2.0.34、Clang 19.1.7、Lean 4.34.1を同じtoolchain.lock.jsonで固定。
CachyOSで不足したDebian互換の共有ライブラリは公式パッケージ索引のSHA256で
確認して作業領域内に展開。システムへのインストールなし。
[toolchain-installed.json](toolchain-installed.json)、[runtime-packages.json](runtime-packages.json)に
バージョン・パス・ハッシュを記録。環境制約は解消し、残る権限障害はない。

## 10案と採否

数値は各案を初期基準と比較した固定7件screenの中央値合計比。
1より大きいと速い。全案でnativeビルド、3固定ファイル×4モードと生成3seedの
出力差分、6,060件の探索状態/燃料golden、7件のタイミング比較に成功。
型・構文上のビルド失敗は修正してから再実験した。失敗回数・同じ案の再試行を
種類数に加えていない。

| # | 仮説・変更 | 速度比 | 採否・理由 | 累積 |
|---|---|---:|---|---:|
'''
for r,reason in zip(ledger,reasons):text+=f"| {r['number']} | {r['idea']} | {r['screen_speedup']:.4f}× | 不採用: {reason} | 1.000× |\n"
text+=f'''
各案の `results/01`～`results/10` に `change.patch`、`build.log`、
`correctness.json`、`fuel.json`、`fuel.log`、`screen.json` と生データ
`screen.json.raw.json.gz` を保存。ローカルの実行ファイルも `binary` に保存
（Git対象外）。[ledger.json](results/ledger.json)に判定の機械可読記録。
2番の案の最初のscreenは0.852倍、その後の独立再試行で0.842倍。
公開用の結果は最後の再試行の生データを採用し、最初の集計は作業ログに残る。
最初のbaseline対同一binaryの探索的測定は重複した正しさ検証と一部重なったため
`preliminary/`として除外。最終測定は全ビルド・テスト終了後に単独で実施。

## 初期対最終の実測

| 主指標（35件固定） | 初期 | 最終 |
|---|---:|---:|
| 壁時計中央値の合計 | {aggregate['baseline_sum_median_ms']:.3f} ms | {aggregate['candidate_sum_median_ms']:.3f} ms |

実測速度比 **{aggregate['primary_speedup']:.4f}×**、対応を維持した5,000回bootstrapの
95%区間 **{aggregate['paired_bootstrap_95_ci'][0]:.4f}–{aggregate['paired_bootstrap_95_ci'][1]:.4f}×**。
同じ実行ファイルの測定変動であり、高速化とは判定しない。
[final-aggregate.json](final-aggregate.json)、[final-measurement.json](final-measurement.json)、
[生データ](final-measurement.json.raw.json.gz)に全反復、quartile、出力ハッシュと環境。
難易度別・全スレッド・遅くなったケースも次に全件掲載する。

| ケース | 初期 median ms (p25–p75) | 最終 median ms (p25–p75) | 速度比 |
|---|---:|---:|---:|
'''
for r in measurement['summary']:
 b=r['baseline']['wall_ms'];c=r['candidate']['wall_ms'];text+=f"| {r['case']} | {b['median']:.3f} ({b['p25']:.3f}–{b['p75']:.3f}) | {c['median']:.3f} ({c['p25']:.3f}–{c['p75']:.3f}) | {r['speedup']:.3f}× |\n"
text+=f'''
## 最終の正しさ検証

- `./verify.sh`（benchmarkも含む）: PASS。型検査、Lean-backed verdict、native QA、
  216 CLIケース、独立の解・一意性・minimality・ratingオラクル、変異検出、
  production燃料枯渇と生成prefix、native/Bend/Node lanes。
- 6,060件の探索状態・燃料比較: frozen goldenと一致。
- 追加の固定基準差分: {diff['comparisons']}比較、{diff['distinct_puzzles']}個の異なる問題。
  全7コマンド、種の境界、異常入力、物理行、16MiB制約、1/8/16スレッドで
  順序保持、独立の解盤面チェックとrating oracleがPASS。
- 元のテスト、法律・証明、入力、出力仕様は削除・弱化していない。
- NodeのFile effectsにはBunが必要で既存の2ケースは実行不可。
  nativeとBendでは全7コマンド検証済み。既存の制約として明示し、性能目標の
  達成判定に利用していない。証明は既存の有限・構造的範囲であり全solverの証明ではない。

[最終ログ](final-verify.log)、[差分結果](final-differential.json)、
[検証summary](final-verification-summary.json)を参照。
基準/最終binary SHA256: `{hashlib.sha256(base.read_bytes()).hexdigest()}`。

## 再現と残ること

[README.md](README.md)に環境準備から全10実験、全テスト、差分、21反復測定の
コマンドを記載。差分patchから各不採用案も再実装可能。
5倍は未達成だが、ユーザー指定の別停止条件（実装・検証した異なる10案）を満たした。
意味のある高速化は確認できず、エンジンコードの採用差分は0。
追加の実験を続ける場合は、今回の測定と独立に新しい仮説を立てる必要がある。
'''
(out/'REPORT.md').write_text(text)
print(aggregate)
