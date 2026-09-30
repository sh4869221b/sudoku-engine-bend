> Historical specification input at sh4869221b/sudoku commit 489b07059c2f1d4cce4997512b0ea4164c2b0f4d. Source-project checkboxes are not completion claims for this independent repository. No original implementation files were read. Current implementation decisions and observed verification are in ../evidence/contracts.md.

# bend-sudoku - Work Plan

## TL;DR (For humans)
<!-- Fill this LAST, after the detailed plan below is written, so it summarizes the REAL plan. -->
<!-- Plain English for a non-engineer: NO file paths, NO todo numbers, NO wave/agent/tool names. -->

**What you'll get:** Bend2 だけで書かれた Sudoku エンジン CLI。7つのコマンド(解く・検証する・解の数を数える・問題を生成する・難易度を評価する・大量処理・性能計測)が全て動き、生成した問題は必ず一意解を持ち、プログラムの性質の一部は数学的に証明され、大量の問題を複数スレッドで並列処理した性能データが残ります。

**Why this approach:** Bend2 の言語制約(停止性検査・値の使い捨てルール・配列の単一所有)を実機で確認した上で、その制約に沿った設計(fuel 方式の再帰・配列盤面・純粋コア+薄い IO)を採用。証明は小さな性質から段階的に積み上げ、無理な主張は正直に弱めます。

**What it will NOT do:** GUI やゲーム画面は作りません。危険フラグ(@unsafe)による実装の近道は使いません。X-Wing 等の高度な解法判定や単一盤面の GPU 並列探索は対象外です。

**Effort:** Large
**Risk:** Medium - 主要ドライバは未成熟な Bend2 ツールチェーン(v2.0.x)と証明作成コストの不確実性。
**Decisions to sanity-check:** 難易度スコアの重み(NS=1/HS=2/LC=5/NP=10)とラベル閾値(<25 Easy/<60 Medium)、`generate --difficulty` を clue 数プロファイルへの写像として実装する点、盤面を `Array<U32>` 128 スロットで表現する点、fuel 定数(solve/count 200000n、digging 20000n)、GPU はプローブ結果次第で CPU ベンチに縮退。

Your next move: 計画の高精度レビュー結果を確認の上、`/ulw-execute bend-sudoku` で実行を開始してください。

---

> TL;DR (machine): Large / Medium risk — Bend2 製 7コマンド Sudoku エンジン(seed・対称性・minimal 対応 generator、一意性 counter、手筋 rater、並列 batch、threads スケーリング bench)+ LAWS/PROOF ゲート + fixtures QA。16 todos・7 waves。

## Scope
### Must have
- Bend2 製 CLI `bend-sudoku`。サブコマンド: `solve / check / count / generate / rate / batch / bench`(全て `main.bend` の `IO.args()` で受ける argv dispatch)。
- 純粋モジュール群(sudoku/*.bend): types, board, parser, validate, candidates, solver, counter, generator, difficulty, batch。
- 盤面表現: `Array<U32>` 128スロット(2の冪必須)、セル値 0(空)/1..9。候補は U32 ビットマスク(bit 1..9)。
- solver: Nat fuel 方式(縮小引数を第1引数へ)。naked single 伝播 + MRV + backtracking。結果は `Solved / Unsolved / OutOfFuel` の3値 ADT。
- counter: 2解で打ち切り。結果は `CountZero / CountOne / CountMany / CountFuel` の4値 ADT と飽和加算 `count_add`。`count_add` は **Many 支配の 4x4 表(可換・可結合)**: 恒等=Zero、`One+One=Many`、`Many` は全値を吸収、`Fuel` は未決(Zero/One)には伝播・決定済み Many は負けない:

  ```
       + Zero One Many Fuel
    Zero Z    O   M   F
    One  O    M   M   F
    Many M    M   M   M
    Fuel F    F   M   F
  ```

  意味: 既に「2 解以上」の確定答え Many があれば、残りの fuel 枯れ(Fuel)は答えを未決に回さない(「 fuel 枯れを隠す」のではなく、答えが既に十分確定しているため)。未決の Zero/One には Fuel のみ伝播する。打切りは**逐次** match 短絡で実装する(並列 let は片側が Many でも他方を停止できないため、一意性判定は必ず逐次版を使う)。公式 law `count_add_assoc` は fuel 除去断片 {Zero, One, Many} の 27 例で述べる(本ツールは単一 finite conjunction のみ); 全 4 値表(とくに `Fuel+Many=Many`)は **QA でランタイム検証する** (`test_count_add_*`)。`count_many_absorb`(Many が全 4 値を吸収)は本表でも真。
- generator: 純粋 xorshift32 PRNG(`Rng` Data ADT、seed 0 は非ゼロに正規化)。seed 再現性必須。完成盤は **canonical 基本パターン `1 + ((row*3 + row/3 + col) mod 9)` への seeded 合法変換**(数字置換・band/stack 内の行・列置換・band/stack 順置換・任意転置。backtracking 失敗が構造的に起きない)を採用。多様性不足が実測された場合のみ、seeded randomized backtracking(MRV solver 流用)へ切替。clue 削除は `Single(pos) | Pair(pos, 80-pos)` の RemovalUnit を1度 seeded shuffle し逐次適用(仮除去後 `CountOne` なら採用、失敗単位の再試行は不要 — 解は clue を減らすほど増えるため)。`--symmetry`(180度回転ペア)、`--clues N`(届かなければ到達値 + TargetUnmet を返す)、minimal モード(残 clue 全てが critical である最終 sweep)。
- difficulty(rate): rate コマンドは手筋ラダー(NS=1, HS=2, LC=5, NP=10; 手筋で解けなければ Hard)で盤を**分析する出力命令**であり、generate --difficulty(後者は clue 数プロファイルへの写像で、rate 結果を保証しない)とは明確に区別する(#21)。rate の内部結果は最低 **手筋で完了 / 停滞(RequiresGuess) / 矛盾 / fuel 枯渇** に区別し、型付き結果(ラベル・Max technique・Steps・Score・status)を返す(#22): 完了は Score<25=Easy / <60=Medium / 他 Hard; 停滞は RequiresGuess を Hard にするが解の存在・一意性は保証しない; 矛盾は明確なエラー; fuel 枯渇は exit 4。
- batch: 1行81文字パズルのファイルを読み、平衡二分木 `Empty | Leaf{index, job} | Fork{left, right}` へ変換し(不足分は Empty で2冪充填)、Fork で並列呼び出し。クロージャは affine で汎用 map が書けないため `batch_solve / batch_check / batch_count / batch_rate` を専用トップレベル def にする。結果は元 index 順に戻す。index は**ファイルの物理行番号(1 起点)** を使用し、`#` 行・空行・不正行はスキップしても index は詰まらせない。出力は **モード毎に内部結果から変換した1行**(`solve`: `<idx> solved:<81chars>` / `unsolved` / `error:fuel`; `check`: `<idx> valid` / `error:<reason>`; `count`: `<idx> count:<0|1|2|fuel>`; `rate`: `<idx> label:<L> tech:<name> steps:<n> score:<n> status:<ok|guess|contradiction|fuel>` 等; JSON 導入は必須ではない)。空ファイル・コメントのみ・全行不正・途中 fuel の aggregate 終了コードを定義し、**全4モードで並列/逐次同値性・入力順保持**を検証(#23)。
- bench: `IO.now` 計時。N ∈ {1,10,100,1000,10000}: `--generate N` ならその N 件(生成設定は固定)、file ならファイルの81文字行 N 件を**どちらか1つだけ**取得し、`N=<n> mode=cpu threads=runtime total_ms=<ms> per_ms=<ms>` を出力(threads は実行時フラグ依存で `runtime` 表記、実スレッド数は evidence)。計測は**入力準備後に開始し、全batch結果を回収してから終了**する(end-to-end は別項目で区別)。比較用コーパスは seed/生成設定/ファイル内容ハッシュで**固定し threads 間で同一入力**を使用。各 N は全て Solved で妥当性/元clue維持を満たすことが成功値; 失敗は時間表に混ぜず件数・状態を記録。N=1000 の中央値が 60 秒超なら 10000 を `skipped`(判定は threads ごと)。GPU は todo 1 判定が gpu-ok の場合の evidence 比較実験のみ(`!` 経路)。evidence に compiler/version・build・実threads・CPU・fuel・反復(3回・warm-up)・中央値元データを保存(#24)。
- law/proof: ルート `LAWS.bend`(主張)+ `PROOF.bend`(証明)。ゲート: `bend PROOF.bend` が `All terms check.` を出すこと。**段階的に追加**: L1 cell_set_get、L2 mirror_involute(Wave 1)、L3 候補 mask が下位9ビット内 + 飽和加算の結合則・Many 吸収則(Wave 3)、L4 batch 木結果 = 逐次結果(Wave 5)。完成盤生成の妥当性保存は実行時 property(qa/run.bend)で固定し、形式証明は段階の余裕が出た時に限る。solver 完全性・「CountOne なら数学的に一意」は初期目標に含めない(spec の段階的導入)。証明不能な主張は弱めて記録(?TODO を最終木に残さない)。**弱い化された各 law の「当初の主張 / 実際の主張 / 対象範囲 / 未保証部分 / 補完QA」を計画または evidence に記載し、`All terms check.` と保証範囲のレビューを別の合格条件にする**(例: mirror は全81位置で確認、cell_set_get は一般証明の対象が限定、mask_in_range は実際の候補生成と対応)。主張を弱めた law には不足を補う QA または明示的な未保証事項を付け、mutation も見直し、実際に偽となる非中央位置等を使う。実行時 property(valid_complete、preserves_clues、対称性、seed 再現性、batch=逐次)は `qa/run.bend` で固定する。
- fixtures: fixtures/{complete,one_empty,easy,medium,hard,invalid,unsolvable,multi_solution,technique}/(パズルは 81 文字の `<slug>.txt`)。期待結果は**コマンド別の .expected ファイル**で保持: `<slug>.solve.expected`(81文字解 または `unsolved`)、`<slug>.check.expected`(`valid`/`invalid`)、`<slug>.count.expected`(`0|1|2`)、`<slug>.rate.expected`(`Easy|Medium|Hard`) — その fixture で意味を持つコマンド分のみ。backfill は solve/count=todo 10、rate=todo 13 が検証済み実行結果で行い、todo 16 と F3 がコマンド別に照合する機械消費者となる。**各 .expected の確定根拠は、被検証コマンドを再実行する以外の手順で説明できること**(`.omo/evidence/` に記録: 独立参照実装、既知解の独立検算、解なしの矛盾証拠、複数解の異なる2解検証; rate は期待手筋・候補除外の根拠・手数/採点規則から期待値を確定)。counter を常に CountOne にする変異で QA が検出されることを最終ゲートに含める。期待値の更新はレビュー対象で、失敗時の自動再生成で差分を消さない。
- 終了コード契約(全コマンド共通の枠 + 個別規定): 0 成功 / 1 usage・ファイル読取失敗 / 2 不正盤(parse・validate 失敗)/ 3 解なし・矛盾 / 4 fuel 枯渇。個別: check=0 valid/2 invalid(理由を stdout)、count=0 で `0|1|2` を出力・4 fuel、generate=0で **stdout は81文字パズル行のみ**、TargetUnmet は **stderr** に `<seed> target=<req> reached=<act>` 行として、fuel 枯渇は exit 4 で部分出力の扱いを明記/1 usage、rate=0(手筋で完了・RequiresGuess は Hard を正常結果として)/2 不正盤/3 矛盾/4 fuel、batch=1行以上処理で 0(不正行は `<idx> error:<reason>` 行を出力して継続)、bench=0/1 usage/2 不正ファイル(#20/#22)。
- fuel 定数(コード内で名前付き定数に): solve CLI・count CLI・batch 葉 = 200000n、digging の count2 呼出し毎 = 20000n。generate 中に fuel 枯渇した場合は生成を中断して exit 4(同一 seed のリトライは決定的なので安全でない旨を stderr に表示)。
- 入力境界: single-user ローカル CLI。信頼しない入力は 81 文字パズル行のみで、parse がそれ以外を拒否する。それ以上の耐性要件は無し。最低セット: 完成盤、1マス空き、行重複、解なし、一意解、複数解、各手筋用盤面(NS/HS/LC/NP が鍵になる盤面)。
- QA ハーネス: `qa/run.bend`(フレームワーク無し言語のため、fixtures を読み各関数を assert し PASS/FAIL 行を出力する Bend プログラム)。コマンド: `bend qa/run.bend`。
- 生成物の保存先 evidence: `.omo/evidence/`(プローブ・タイミング・QA 出力)。

### Must NOT have (guardrails, anti-slop, scope boundaries)
- GUI/対話ゲーム機能、hub publish、JS 相互運用、App/graphics、TLS/HTTP。
- `@unsafe` の使用(どうしても必要になった時点で作業を停止しユーザーに報告。黙って使わない)。
- X-Wing 等の高度手筋、Solver 全体の完全証明(仕様が段階的導入を指示)。
- 単一盤面の GPU 並列探索(divergent ワークは GPU 不利が公式見解。GPU は bench の比較実験のみ)。
- README/design docs 等の過程資料(この計画と実機 evidence が全て)。
-言語内テストフレームワークの自作以上のテスト基盤投入。

## Verification strategy
> Zero human intervention - all verification is agent-executed.
- Test decision: **tests-after + laws-first**。純粋関数は `qa/run.bend` ハーネス(実機 `bend qa/run.bend`、全行 PASS で合格)、性質は `bend PROOF.bend`(All terms check. で合格)、ユーザー可視面は CLI の実機実行(`bend main.bend <args>` とネイティブバイナリ)で stdout/終了コードを直接アサート。フレームワークは導入しない(Bend に無いため)。
- 各 todo の QA は「happy + failure」シナリオを必ず含み、evidence を `.omo/evidence/task-<N>-bend-sudoku.<log>` に保存する。CLI を実装する todo の QA は happy path をネイティブバイナリでも再実行する。
- ベンチのスケーリング測定: ネイティブバイナリを `--threads 1 / 8 / 16` で3回ずつ実行し中央値を記録する(60 秒上限規則は scope の bench 項参照)。
- Evidence: `.omo/evidence/task-<N>-bend-sudoku.<ext>`

## Execution strategy
### Parallel execution waves
- Wave 0: ツールチェーン確認(GPU プローブ・サブディレクトリ import プローブ・git init・fixtures 種)。
- Wave 1: core(types/board/parser/validate)+ QA ハーネス骨格 + laws L1/L2。
- Wave 2: search(candidates/solver)+ CLI solve。
- Wave 3: counter + count CLI + law L3(候補↔ユニット制約、証明不能なら正直に弱めて記録)。
- Wave 4: generator(RNG・完成盤・digging・対称性・minimal)+ generate CLI。
- Wave 5: difficulty(rate CLI)+ batch(fork-join)+ batch CLI。
- Wave 6: bench + スレッドスケーリング測定 + 全体グリーン确认。
- 各 Wave のゲート: `bend main.bend --checkup`(全 import 単独 check)→ `bend PROOF.bend` → `bend qa/run.bend` → 該当 CLI の実機実行。

### Dependency matrix(todos の Blocked-by/Blocks 行から機械的に派生。矛盾時は todo 側を正とする)
| Todo | Depends on | Blocks | Can parallelize with |
| --- | --- | --- | --- |
| 1 | なし | 3..16 | 2 |
| 2 | なし | 4,6,7,9,10,12,13 | 1 |
| 3 | 1 | 4,5,6,7 | 2 |
| 4 | 3 | 5,6,7,8 | なし |
| 5 | 3,4 | 10 | なし |
| 6 | 2,4 | 7,13 | 5 |
| 7 | 6 | 8,9,11,12 | なし |
| 8 | 7 | 10,15,16 | 9 |
| 9 | 7 | 10,12,14 | 8 |
| 10 | 8,9 | 12,14 | 11 |
| 11 | 7 | 12 | 9,10 |
| 12 | 9,10,11 | 13,14,15 | なし |
| 13 | 12 | 14,15,16 | なし |
| 14 | 9,12,13 | 15,16 | なし |
| 15 | 8,12,13,14 | 16 | なし |
| 16 | 1..15 全て | F1..F4 | なし |

## Todos
> Implementation + Test = ONE todo. Never separate.
<!-- APPEND TASK BATCHES BELOW THIS LINE WITH edit/apply_patch - never rewrite the headers above. -->
- [x] 1. リポジトリ基盤 + ツールチェーンプローブ(Wave 0)
  What to do: `git init` + 初期コミット。skeleton 作成(sudoku/、fixtures/{easy,medium,hard,invalid,multi_solution,technique}/、qa/、.omo/evidence/)。プローブA: サブディレクトリ import(root から `import ./sudoku/types.bend as T` する stub を `bend main.bend --checkup` で検証)。プローブB: GPU — `CUDA_HOME=/opt/cuda bend <tiny ! program>.bend -o <bin>` を試行し、成功/失敗の判定を記録(CUDA の install や system 変更は禁止、失敗は GPU 実験 Skip の根拠)。プローブC: `bend --version` が 2.0.10 であることの確認。
  Must NOT do: CUDA やパッケージの install/upgrade、system ファイル変更、@unsafe。
  Parallelization: Wave 0 | Blocked by: なし | Blocks: 3〜16
  References: bend guide(https://github.com/bendlang/bend/blob/main/guide/GUIDE.md の Modules/Tooling 節、本機 copy は /tmp/bend-guide.txt)。ドラフト .omo/drafts/bend-sudoku.md Findings。プローブ済み知見(Array/fuel/import 規約、/tmp/p14・/tmp/dia)。
  Acceptance criteria: `git log --oneline` に初期コミット。`bend --version` = 2.0.10。プローブA の stub が `bend main.bend --checkup` で緑。.omo/evidence/task-1-gpu-probe.log に gpu-ok|gpu-unavailable の判定と根拠が残る。
  QA scenarios: happy — `bend --version` 実行で 2.0.10、checkup 緑(evidence: .omo/evidence/task-1-checkup.log)。failure — GPU ビルドが失敗した場合、エラーを握り潰さず log に判定として記録(evidence: task-1-gpu-probe.log)。
  Commit: Y | chore(repo): scaffold bend-sudoku workspace
  Recommended task executor category: quick — 単一セッションの機械的 setup + プローブ。

- [x] 2. fixtures コーパス整備(Wave 0)
  What to do: 各 fixture ディレクトリに 81 文字の `<slug>.txt` とコマンド別期待ファイル(`<slug>.solve.expected` / `<slug>.check.expected` / `<slug>.count.expected` / `<slug>.rate.expected`、その fixture で意味を持つコマンド分のみ。現時点で分かる構造的事実のみ記載し、実値は todo 10/13 が backfill)を配置。命名規約(後続 todo の QA が参照する具体名): complete/complete.txt、one_empty/one_empty.txt、easy/easy.txt、medium/medium.txt、hard/hard.txt(Inkala)、invalid/rowdup.txt・invalid/badchar.txt、unsolvable/unsolvable.txt、multi_solution/multi.txt、technique/{naked_single,hidden_single,locked_candidates,naked_pair}/<同名>.txt。必須セット: 完成盤、1マス空き、行重複、不正文字、解なし、一意解 easy(36+ clues)/medium/hard、複数解、手筋用 4種。
  Must NOT do: 未検証の .expected を書かない(一意性・難易度ラベルは後続 todo の実行結果で裏取りして確定。この todo 時点では構造的事実のみ記載)。
  Parallelization: Wave 0 | Blocked by: なし | Blocks: 4,6,7,9,10,12,13 | Can parallelize with: 1
  References: spec(ユーザー提供仕様の fixtures 節)。ultrabrain 勧告の fixture 最低セット。
  Acceptance criteria: 全 .txt が 81 文字(evidence に wc -c 記録)。multi_solution の Many 判定は todo 10 で確定。
  QA scenarios: happy — `for f in fixtures/**/*.txt; do echo "$f $(tr -d '\\n' < $f | wc -c)"; done` が全て 81(evidence: task-2-fixtures.log)。failure — 81 文字でないファイルを修正して再記録。
  Commit: Y | chore(fixtures): add sudoku fixture corpus
  Recommended task executor category: quick — データ整備。

- [x] 3. sudoku/types.bend + sudoku/board.bend(Wave 1)
  What to do: types.bend — 定数(CELLS=81n 等)、`type SolveResult is Data: Solved{} Unsolved{} OutOfFuel{}`、`type Count is Data: CountZero{} CountOne{} CountMany{} CountFuel{}`(fuel 枯渇は Zero に偽装せず専用値で表す。count_add は CountFuel を支配的に伝播)。board.bend — Board=`Array<U32>`(128 スロット、0..80 がセル、0=空): empty_board、get_cell/set_cell(読み書きは `Array.get(U32, a, i)` / `a[i] <- v`、返り値ペアの分解はヘルパー def へ引数で渡す規約)、row_indices/col_indices/box_indices(b: 0..8 → (b/3)*27+(b%3)*3 起点の 9 セル)、peers(pos)(同row/col/box の 20 セル)、is_full、count_clues、mirror(pos)=80-pos。qa/run.bend の骨格作成(PASS/FAIL 行出力、現時点は board の assert のみ)。
  Must NOT do: 他ファイルへの手出し、@unsafe、`+a: Array<U32>`(Array は Type — 実機検証済みの不可パターン)。
  Parallelization: Wave 1 | Blocked by: 1 | Blocks: 4,5,6,7 | Can parallelize with: 2
  References: 実機プローブ知見(/tmp/p14: fill+get+対分解ヘルパー、/tmp/p10〜p12 の失敗パターン: 計算値の match/分解禁止、do-block 内の match 禁止)。bend guide Arrays 節。ultrabrain 勧告「計算値は段階ヘルパーへ引数で渡す」。
  Acceptance criteria: `bend main.bend --checkup` 緑。`bend qa/run.bend` が全 PASS 行(0 FAIL)。
  QA scenarios: happy — qa/run.bend が set/get 一致、mirror(mirror(pos))==pos、ユニット 27・peers 20 を assert して PASS(evidence: task-3-board-qa.log)。failure — 意図的に間違った定数で qa が FAIL を出す Mutation を一度だけ実施し戻す(evidence: task-3-mutation.log)。
  Commit: Y | feat(sudoku): board types and array-backed board ops
  Recommended task executor category: unspecified-high — Bend 特有のアフィン/scrutinee 制約下での複数ファイル実装。

- [x] 4. sudoku/parser.bend + sudoku/validate.bend(Wave 1)
  What to do: parser.bend — `parse81(s: String) -> Result<&1, &1, ParseErr, Board>`(String.to_list → Char 列、空白/改行除去後 81 文字チェック、'1'..'9' は Char.to_u32 - 48、'0' と '.' は空、他は ParseErr{BadChar}、長さ不一致は ParseErr{BadLength})、`show(b: Board) -> String`(空は '0')。validate.bend — `validate(b: Board) -> Maybe<&2, ValidErr>`(行/列/box の非ゼロ重複検出、ValidErr は unit 種別+index)、`is_complete(b)`、`preserves_clues(p, sol)`(全 clue セル一致)。
  Must NOT do: 不当文字を黙って正規化受入(エラーで返す)。
  Parallelization: Wave 1 | Blocked by: 3 | Blocks: 5,6,7,8 | Can parallelize with: なし
  References: bend base の String/Char API(/tmp/bend-base.txt: String.to_list/get/take/drop/from_list、Char.is_digit/to_u32)。fixtures(2)。
  Acceptance criteria: `bend qa/run.bend` に parser/validate の assert 追加、全 PASS — 全 fixture で parse→show→parse 不変、invalid fixture が validate 失敗、complete fixture が is_complete 真+validate 成功。
  QA scenarios: happy — `bend qa/run.bend` 全 PASS(evidence: task-4-parser-qa.log)。failure — 不正文字を含む 81 文字列で ParseErr になることを qa 内で直接 assert(CLI は未実装のため)(evidence: task-4-parse-err.log)。
  Commit: Y | feat(sudoku): 81-char parser and rule validator
  Recommended task executor category: unspecified-high — String/Char API とアフィン規約を跨ぐ実装。

- [x] 5. LAWS.bend + PROOF.bend L1/L2(Wave 1)
  What to do: root に LAWS.bend(主張)+ PROOF.bend(証明)。L1: `law cell_set_get` — `for -b: Array<U32>, +i: U32` で set 後 get が同じ値。L2: `law mirror_involute` — `for +p: U32 where is_pos(p)` で `mirror(mirror(p)) == p`。証明は `{==}` 反射とヘルパー def 中心。`bend PROOF.bend` がゲート。
  Must NOT do: `?TODO` を最終木に残す(証明できない主張は書かない)。@unsafe に逃げない。証明が設計どおりに書けない場合は主張を弱めた形に置換し判断を evidence に記録(spec の段階的導入に一致)。
  Parallelization: Wave 1 | Blocked by: 3,4 | Blocks: 10 の law 追加 | Can parallelize with: なし
  References: bend guide Laws and Proofs 節({==}, %rewrite, 再帰=IH、Equal.sym/trans/cong)。librarian 報告(tests/proof/ の前例、for/where/exs 構文)。プローブ知見(match はパラメータのみ)。
  Acceptance criteria: `bend PROOF.bend` が `All terms check.` を出力。
  QA scenarios: happy — `bend PROOF.bend` 緑(evidence: task-5-proof.log)。failure — 主張を意図的に偽(`mirror(p) == p`)にして赤を記録し戻す(Mutation、evidence: task-5-mutation.log)。
  Commit: Y | test(laws): cell set/get and mirror involute laws
  Recommended task executor category: deep — Bend の証明はタクティクス無しで、証明組み立てに本質的な推論が必要。

- [x] 6. sudoku/candidates.bend(Wave 2)
  What to do: `candidates_at(b, pos) -> U32`(**bit d = 数字 d(bit 1..9、bit 0 不使用)** のため基準マスクは `1022`: `candidates_at(b, pos) = 1022 & ~(row_used | col_used | box_used)`)、`mask_count`、`mask_singleton`、`mask_digit(mask, n) -> Maybe`(昇順 n 番目)、`mask_digits(mask) -> List<U32>`。ユニット集約は board.bend の index リスト + List.foldl。
  Must NOT do: 81 セル分の恒久候補配列(todo 13 の rating のみ恒久候補を持つ — ultrabrain 勧告)。
  Parallelization: Wave 2 | Blocked by: 2,4 | Blocks: 7,13 | Can parallelize with: 5
  References: ultrabrain 勧告 §1(9ビット U32 mask・再計算方式)。board.bend(3)。fixtures(2)。
  Acceptance criteria: qa/run.bend — one_empty の空セル候補がちょうど1、complete に空セルなし、手作り盤で期待 mask 一致。
  QA scenarios: happy — `bend qa/run.bend` 全 PASS(evidence: task-6-candidates-qa.log)。failure — invalid fixture で候補 0 のセルが検出されることを assert(evidence: task-6-zero-cand.log)。
  Commit: Y | feat(sudoku): candidate bitmasks from unit constraints
  Recommended task executor category: unspecified-low — 単一ファイル・明確なアルゴリズムの翻訳。

- [x] 7. sudoku/solver.bend(Wave 2)
  What to do: fuel-first 署名(`def solve(fuel: Nat, b: Array<U32>) -> ...`、縮小引数第1引数規約)。構成: (a) naked single 伝播の固定点(候補1セルを配置、候補0で矛盾打切り)、(b) MRV セル選択(空セル走査で最小候補数、同率は昇順位置で決定的)、(c) 数字昇順バックトラッキング。**undo-by-swap**: 逐次 DFS では `Array.swap` の旧値返り値で配置を戻すため clone 不要。返り値は `SolveResult & Array<U32>`(常に盤面を同伴: Solved 時=解、それ以外=入力を消費したままの盤面。統計は不要 — consultant M7)。fuel 尽きで OutOfFuel。solver は純粋に保ち(自己検証は qa 側)。
  Must NOT do: @unsafe。単一盤の探索並列化。クロージャの複数呼出。
  Parallelization: Wave 2 | Blocked by: 6 | Blocks: 8,9,11,12 | Can parallelize with: なし
  References: ultrabrain 勧告 §1 全体(MRV 走査構造・段階ヘルパー・fuel 第1引数)。実機規約(縮小引数第1位、+x 再利用、ヘルパー def)。bend guide Recursion and Termination 節。architect 勧告 §6-2(3値結果)。
  Acceptance criteria: qa/run.bend — easy/one_empty を Solved、unsolvable を Unsolved、hard(Inkala)を native で Solved(10秒以内を目安、超過時は計測値を evidence に記録して todo 15 で再検討 — 黙って諦めない)、fuel 極小で OutOfFuel。Solved 解が preserves_clues+validate を通る。
  QA scenarios: happy — solver assert 全 PASS(evidence: task-7-solver-qa.log)。failure — fuel=1 で hard を解かせ OutOfFuel を assert(evidence: task-7-oof.log)。
  Commit: Y | feat(sudoku): fuel-bounded MRV backtracking solver
  Recommended task executor category: deep — 終端検査・アフィン・scrutinee 制約と探索の相互作用が最難所。

- [x] 8. main.bend CLI dispatch + solve/check コマンド(Wave 2)
  What to do: main.bend — `main() -> IO(Unit)` で `IO.args()` を受けて先頭要素で dispatch。未対応は usage を stderr + exit 1。`solve <puzzle>`: parse → validate(初期盤違反は exit 2 + stderr)→ solve(既定 fuel 200000n)→ Solved なら 81 文字解を stdout、Unsolved は exit 3、OutOfFuel は exit 4。`check <puzzle>`: parse → validate → valid なら `valid` を stdout + exit 0、invalid は `invalid <unit>:<index>` を stdout + exit 2。終了コード: 0 成功 / 1 usage / 2 不正盤 / 3 解なし / 4 fuel 枯渇(scope の全コマンド終了コード表参照)。ネイティブビルド確認(`bend main.bend -o bin/bend-sudoku`、bin/ は .gitignore)。
  Must NOT do: env フォールバック等の副入力経路(2.0.10 IO.args 実機検証済み)。
  Parallelization: Wave 2 | Blocked by: 7 | Blocks: 10,15,16 | Can parallelize with: 9
  References: 実機検証(IO.args 両レーン、--threads は剥がれる)。bend guide IO 節。librarian 報告(exit コードは io_exit)。
  Acceptance criteria: `bend main.bend solve <easy81>` → exit 0 + 81 文字解。`bend main.bend check <valid81>` → exit 0 + `valid`。`bend main.bend check <rowdup81>` → exit 2 + `invalid row:<n>`。invalid solve → 2。unsolvable solve → 3。usage なし → 1。全て .omo/evidence/task-8-cli.log に記録。
  QA scenarios: happy — 上記 5 ケース実機実行(stdout+exit code capture)。failure — 81 文字未満引数で parse エラー系 exit 2。ネイティブバイナリで同 5 ケース再実行(evidence: task-8-cli.log)。
  Commit: Y | feat(cli): argv dispatch and solve/check commands
  Recommended task executor category: unspecified-high — IO 境界と終了コード契約の実装。

- [x] 9. sudoku/counter.bend(Wave 3)
  What to do: `count2(fuel: Nat, b: Array<U32>) -> Count`(Zero/One/Many、solver と同じ伝播+MRV+バックトラッキングを流用)。**逐次 match 短絡**: 各反復の冒頭で累積 Count を match し、Many なら次の候補枝を呼ばずに即返す(子の探索呼出しが Many の match 枝に存在しない形)。`count_add(a, b) -> Count` は **Many 支配の 4x4 表**(`Fuel+Many=Many`、Many が全値を吸収、Fuel は未決 Zero/One にのみ伝播、可換・可結合 — Scope の counter 項・LAWS.bend で表)を実装する。並列還元は使わない(ultrabrain 勧告: parallel let は 2解で停止しない)。
  Must NOT do: 2解後も探索を続ける実装。全解列挙。
  Parallelization: Wave 3 | Blocked by: 7 | Blocks: 10,12,14 | Can parallelize with: 8
  References: ultrabrain 勧告 §2(3値 ADT・飽和加算・逐次短絡の構造)。solver.bend(7)。
  Acceptance criteria: qa/run.bend — one_empty → CountOne、unsolvable → CountZero、multi_solution → CountMany、clue を1つ足した multi_solution → CountOne 以下。
  QA scenarios: happy — `bend qa/run.bend` 全 PASS(evidence: task-9-counter-qa.log)。failure — fuel=1 で OutOfFuel 相当の打切りを assert(evidence: task-9-fuel.log)。
  Commit: Y | feat(sudoku): saturating solution counter with early stop
  Recommended task executor category: deep — 短絡再帰の構造が終端検査とアフィン規約と噛み合う必要がある。

- [x] 10. count CLI + 実行時 property + law L3(Wave 3)
  What to do: `count <puzzle>` — parse/validate 後 count2 を実行し `0|1|2`(2=Many)を stdout、fuel 枯渇は exit 4。実行時 property を qa/run.bend に追加: solver の Solved 解が valid_complete + preserves_clues(ultrabrain 勧告の最低 property 1/2)。law L3 を LAWS/PROOF に追加: `law mask_in_range`(候補 mask は bit 1..9 のみ: `mask & ~1022 == 0`)、`law count_add_assoc`/`law count_many_absorb`(飽和加算の結合則・吸収則)。証明不能な主張は弱めて記録(?TODO を最終木に残さない)。
  Must NOT do: 「CountOne なら数学的に一意」の完全証明(spec が段階的導入を指示、初期スコープ外)。
  Parallelization: Wave 3 | Blocked by: 8,9 | Blocks: 12,14 | Can parallelize with: 11
  References: ultrabrain 勧告 §2・最小 law リスト(1/2/3番)。todo 5 の LAWS/PROOF 構造。fixtures(2)。
  Acceptance criteria: `bend main.bend count` に multi.txt の 81 文字を渡す → `2`、one_empty → `1`、unsolvable → `0`。`bend PROOF.bend` 緑。qa に solver 解の property チェック追加で全 PASS。**backfill**: 各 fixture の `.count.expected` と `.solve.expected` を検証済み実行結果で確定させる。
  QA scenarios: happy — CLI 3 ケース実機実行 + `bend PROOF.bend` 緑(evidence: task-10-count-cli.log, task-10-proof.log)。failure — solver の解を意図的に1セル破壊した Mutation で preserves_clues チェックが FAIL を出すことを一度だけ確認し戻す(evidence: task-10-mutation.log)。
  Commit: Y | feat(cli): count command and solver-output properties
  Recommended task executor category: unspecified-high — CLI 拡張 + 証明追加の複合。

- [x] 11. sudoku/generator.bend — Rng + 完成盤生成(Wave 4)
  What to do: `type Rng is Data: Rng{state: U32}` + `rng_next(r) -> (Rng & U32)`(xorshift32、seed 0 は 0x9E3779B9 に正規化)。完成盤は canonical 基本パターン `1 + ((row*3 + row/3 + col) mod 9)` に seeded 合法変換を適用: 数字置換(9!)、band 内行置換(3!^3)、band 順(3!)、stack 内列置換(3!^3)、stack 順(3!)、任意転置(2倍)。置換は rng から Fisher–Yates で決定的に導出。
  Must NOT do: 空盤 randomized backtracking を主経路にしない(フォールバック: 変換方式の多様性不足が実測された場合のみ、seeded MRV backtracking へ切替 — 切替時は evidence に理由を記録)。
  Parallelization: Wave 4 | Blocked by: 7 | Blocks: 12 | Can parallelize with: 9,10
  References: ultrabrain 勧告 §3 完成盤(基本パターン+置換、backtracking 失敗なし)・§5 RNG(xorshift32、seed 0 正規化、state-passing)。bend base U32 bit API。
  Acceptance criteria: qa/run.bend — 同一 seed 2回 → 同一盤、seed 1..10 で 10 種以上の異なる盤、全出力が is_complete+validate 成功。
  QA scenarios: happy — `bend qa/run.bend` generator assert 全 PASS(evidence: task-11-gen-qa.log)。failure — seed 0 が固定点に落ちないことを assert(正規化の確認)(evidence: task-11-seed0.log)。
  Commit: Y | feat(sudoku): seeded rng and full-board generation
  Recommended task executor category: unspecified-high — 置換導出と決定性契約の実装。

- [x] 12. digging + minimal + generate CLI(Wave 4)
  What to do: RemovalUnit(`Single{pos}` または symmetry 時 `Pair{pos}` で 0..40、pos 40 のみ Single)+ 一度きりの seeded shuffle → 逐次適用: 仮除去 → `count2 == CountOne` なら確定、そうでなければ元に戻す(失敗単位の再試行不要 — 解は clue を減らすほど増える)。digging 内の count2 は fuel 20000n(scope の fuel 定数表)、枯渇時は exit 4 で中断。`--clues N` 未達時は到達 clue 数を **stderr** の `<seed> target=<req> reached=<act>` 行で報告し exit 0(成功パズルは stdout の1行ずつのみで、診断は stdout へ出さない)。`--difficulty <easy|medium|hard>` は clue 数プロファイルへの写像(easy≥36 / medium 30-35 / hard<30)であり、**`rate` による実測難易度評価とは別物**でその出力を保証しない; help で「clue 数プリセットであり rate 結果は保証しない」と明記。`--clues` と `--difficulty` の同時・逆順指定の期待結果を固定し、引数順で意味が変わらないようにする(未実装ラベルは #14 でエラー)。minimal モード: 最終 sweep で残 clue 各々を外して count2 し、CountOne のままなら削除確定。`--minimal` 単独(非対称)時は単一 clue の厳密 minimal を保証。`--symmetry` 時は最終 clue が全 pos で is_clue(pos)==is_clue(80-pos)。**`--symmetry` × `--minimal` の併用時は sweep も Pair 単位(pos 40 のみ Single)で、これは「ペア最小」であり単一 clue 単位の厳密 minimal に相当しない; その場合生成器は「厳密 minimal 達成済み」と報告しない**。CLI `generate [--seed N] [--count K] [--clues N] [--difficulty L] [--symmetry] [--minimal]`: 成功パズルを1行ずつ stdout。既定 seed は指定しなければ 0(決定的)。
  Must NOT do: 除去の並列試行(同一盤上の除去は直列 — ultrabrain 勧告)。difficulty による品質保証(--clues は clue 数の目標であって難易度保証ではない)。
  Parallelization: Wave 4 | Blocked by: 9,10,11 | Blocks: 13,14,15 | Can parallelize with: なし
  References: ultrabrain 勧告 §3 手掛かり除去(RemovalUnit、shuffle 1回、TargetUnmet、非単調性の注意)。counter(9)。spec の Generator・対称性・minimal 節(--count/--difficulty は spec の CLI 例示に基づく)。
  Acceptance criteria: `bend main.bend generate --seed 42` を2回実行して同一出力(evidence 記録)。出力パズルの count が全て 1。`--symmetry` で全 pos が is_clue(pos)==is_clue(80-pos)。`--minimal`(非対称)で生成パズルから任意の1 clue を除くと count が 2+(サンプル検証)。**`--symmetry --minimal` 時は「ペア最小」を独立検証**: 残 clue は全ペア(中央は単一)が critical であり、単一 clue 単位の厳密 minimal は要求しない(生成器は厳密 minimal を報告しない)。TargetUnmet は stdout に現れず **stderr** で確認できる; 正常終了の stdout は `<count>` 行の81文字パズルのみ(生成→ファイル→`batch count` に渡しても診断行が混入しない)。
  QA scenarios: happy — 上記を CLI+qa で実機確認(evidence: task-12-gen-cli.log)。failure — 極小の --clues 1 で TargetUnmet が返ることを assert(無理な目標で異常終了しない)(evidence: task-12-unmet.log)。
  Commit: Y | feat(cli): puzzle generator with uniqueness, symmetry, minimal
  Recommended task executor category: deep — 一意性ループ・決定性・target 契約の組み立てが難しい。

- [ ] 13. sudoku/difficulty.bend + rate CLI(Wave 5)
  What to do: 恒久候補を持つ盤状態 `type Cell is Data: Fixed{d: U32} Open{mask: U32}`(81 セル)。手筋ラダーを毎回最弱から1手適用し先頭へ戻る: Naked Single → Hidden Single → Locked Candidates(pointing/claiming)→ Naked Pair → 進展なしで RequiresGuess。同率手は unit 種別・unit 番号・位置・数字の固定順で決定的に選ぶ。1パターン=1 step(**同じ状態への no-op は step を数えない**)。重み NS=1 HS=2 LC=5 NP=10(合計=Score)。rater の内部結果は最低 **手筋で完了 / 停滞(RequiresGuess) / 矛盾 / fuel 枯渇** に型付き結果として区別し status 付きで返す(#22): 完了は Score<25=Easy / <60=Medium / 他 Hard(手筋で解けない場合は RequiresGuess=Hard、ただし解の存在・一意性は保証しない); 矛盾は**矛盾を検知した明示的エラー結果(exit 3 相当)**; fuel 枯渇は **exit 4**。fuel(約729ステップ上限)で終端保証。CLI `rate <puzzle>`: `Difficulty: <label>` / `Max technique: <name>` / `Steps: <n>` / `Score: <n>` を stdout; 矛盾/fuel 時はその終了コードで終了。rate は **手筋分析命令**であり、generate --difficulty(clue 数プロファイル)とは別物。
  Must NOT do: X-Wing 等の高度手筋。探索ノード数による代替評価(仕様外)。
  Parallelization: Wave 5 | Blocked by: 12 | Blocks: 14,15,16 | Can parallelize with: なし
  References: ultrabrain 勧告 §4(Cell ADT、ラダー、決定的 tie-break、fuel 729、1パターン1step)。spec 難易度評価節。candidates(6)。
  Acceptance criteria: qa/run.bend — technique fixtures がそれぞれ期待手筋で解け;**fixture の期待ラベルは実装前に確定した採点規則(Score<25=Easy/<60=Medium/他 Hard)から導く**(fixture 名と期待ラベルが食い合う場合はルールに従い再分類し、easy fixture の期待値はその規則の出力とする)。hard(Inkala)は Hard または RequiresGuess。`bend main.bend rate <easy81>` が指定形式で4行出力。**easy fixture の Score 計算根拠を evidence に残す**(例: 41 step → Score=41 → Medium)。境界値 **24/25/59/60** と **RequiresGuess** のラベルテストを qa に追加。`.rate.expected` は実装前に確定した規則の値で定まり、実行結果に無条件に合わせてはならない。
  QA scenarios: happy — fixture 期待ラベル一致 + CLI 出力形式確認(evidence: task-13-rate-qa.log)。failure — 空盤(制約なし)が RequiresGuess/Hard になることを assert(evidence: task-13-empty.log)。
  Commit: Y | feat(cli): human-technique difficulty rater
  Recommended task executor category: deep — 4種の手筋実装と決定的選択規約が最大の実装重量(ultrabrain 評価: 人間技法評価が最重)。

- [x] 13-fix. 既存不具合修正: solver.bend の `Done` コンストラクタが Base `Result.Done` と衝突し `bend main.bend --checkup` が赤(2026-09-19 実機確認、abcc3b1 時点から存在)。`SolverState` の `Done` を `SolveDone` に改名し、checkup 緑 + qa 132 PASS + CLI solve スモークで検証する。counter/generator の `CounterDone`/`DigDone` 命名規約に合わせる。
  Parallelization: Wave 5 | Blocked by: なし | Blocks: 13(ゲート)
  Acceptance criteria: `bend main.bend --checkup` 全緑。`bend qa/run.bend` 132 PASS 変化なし。`bend main.bend solve <easy81>` exit 0。evidence: task-13-done-rename.log。
  Commit: Y | fix(sudoku): rename solver Done constructor to SolveDone

- [x] 13-mig. bend コンパイラを計画実行中に 2.0.19 へ更新(2026-09-20 ユーザー指示: 既存コードも新コンパイラでエラーになる場合は修正すること)。破壊的変更 2 件に対応:
  (1) bare operator の型注記必須化(2.0.16 以降): `bend main.bend --checkup` / `bend PROOF.bend` が赤(初出: sudoku/board.bend peers_go の `U32.from_nat(80n - pp)`、全 import 先に同位置が現れる)。全 bare operator に `(a - b : Nat)` 形式の注記のみを付与(ロジック変更禁止)。
  (2) 2.0.19 の `..` import 連鎖リゾルバ回帰(root が /tmp/resolver-repro で独立再現、worker も /tmp/migr で隔離再現): サブディレクトリ(qa/)から `../sudoku/x.bend` 経由で import した中間モジュールが `./` import + 修飾名(B.box_of 等)を使うと `expected: a defined name / observed: U32../sudoku/board.box_of` で失敗。sibling `./` import は健全(root 呼び出しも健全)。唯一の回避策は QA ハーネスの `..` import 排除: **qa/run.bend をルートの qa_run.bend へ移動**し import を `./sudoku/...` に書き換える。これに伴い **QA ゲートコマンドは `bend qa_run.bend` に変更**(本 checkbox が変更の権威ある記録。以後、全 wave ゲート・todo 16・F3 の QA 実行は新コマンドを使用)。fixtures 読み取りは CWD 相対(`"fixtures/..."`)なので影響なし。
  Parallelization: Wave 5 | Blocked by: なし | Blocks: 13(ゲート)
  Acceptance criteria: `bend main.bend --checkup` rc=0、`bend PROOF.bend` が `All terms check.`、`bend qa_run.bend` が `RESULT: 132PASS 0FAIL`(挙動不変)、`bend main.bend solve -- <easy81>` exit 0 + 81文字解。evidence: task-13-mig.log(Bend 2.0.19、注記箇所一覧、リゾルバ回帰の再現、移動、修正後 4 ゲート出力)。
  Commit: Y | fix(sudoku): annotate bare operators for bend 2.0.19
  Recommended task executor category: quick — 機械的な注記スイープ + ファイル移動。
  2026-09-20 追記(2.0.20): bend-bin 2.0.20-1 への再更新で全ゲートを再実行 — checkup rc=0 / PROOF `All terms check.` / qa_run.bend `RESULT: 132PASS 0FAIL` / solve exit 0+81文字解 / ネイティブビルド+solve・check スモーク緑。**コード変更不要**(2.0.19 移行がそのまま有効)。ネイティブビルドは新規 worktree に gitignored な `bin/` が無いため `mkdir -p bin` が必要(環境起因・コード不変)。evidence: task-13-mig-2.0.20.log(w5)。
  2026-09-21 追記(2.0.21): bend-bin 2.0.21-1(pacman確認)への再々更新で全ゲートを baseline(a9f3a94、S2 WIP stash時)で再実行 — checkup rc=0 / PROOF \`All terms check.\` / qa_run.bend \`RESULT: 132PASS 0FAIL\` / solve・ネイティブビルド+スモーク緑。**コード変更不要**(2.0.19移行がそのまま有効)。evidence: task-13-mig-2.0.21.log(w5)。
  2026-09-21 追記(2.0.23): bend 2.0.23(2.0.24 は広告のみ・未導入)で全ゲートを baseline(3d65fbf、S2 完了時点)で再実行 — checkup rc=0 / PROOF All terms check. / qa_run.bend RESULT: 132PASS 0FAIL / solve スモーク緑(81文字解)。**コード変更不要**(2.0.19移行がそのまま有効)。evidence: task-13-mig-2.0.23.log(w5)。

- [ ] 14. batch 木 + batch CLI(Wave 5)
  What to do: `type JobTree is Data: JEmpty{} JLeaf{idx: U32, puzzle: ...} JFork{l: JobTree, r: JobTree}`(不足分は JEmpty で 2冪充填)。`batch_solve / batch_check / batch_count / batch_rate` を専用トップレベル def として実装(クロージャ affine のため汎用 map 不使用)、JFork で `a b = batch_x(...) batch_x(...)` の並列呼び出し。結果は元 index 順へ復元。CLI `batch <file> <mode>`: `#` コメント・空行スキップ、1行=1パズル、index は**ファイルの物理行番号(1 起点)** を使用し、スキップ行でも index は詰まらせない。出力は **モード毎に内部結果から変換した1行**(`solve`: `<idx> solved:<81chars> / unsolved / error:fuel`; `check`: `<idx> valid / error:<reason>`; `count`: `<idx> count:<0|1|2|fuel>`; `rate`: `<idx> label:<L> tech:<name> steps:<n> score:<n> status:<ok|guess|contradiction|fuel>` 等; JSON 導入は必須ではない)。不正行は `<idx> error:<reason>` 行を出力して処理継続(≥1行処理で exit 0)。law L4: `law batch_eq_seq` — batch 木の結果が逐次 fold と一致(構造的帰納法: JEmpty/JLeaf は反射、JFork は IH)。全4モード(solve/check/count/rate)で並列/逐次同値性・入力順保持を QA で検証。
  Must NOT do: 2冪充填をせず木を偏らせる(fork-join 均衡契約違反)。モード毎に木コードを複製する代わりに共通化しすぎて affine エラーに悩む(まず専用 def、共通化は template が安定してから)。
  Parallelization: Wave 5 | Blocked by: 9,12,13 | Blocks: 15,16 | Can parallelize with: なし(batch_rate が difficulty(13)を import するため)
  References: ultrabrain 勧告 §6(平衡木・Empty 充填・専用 def・index 復元)。実機知見(並列 let 構文 a b = f(x) g(y))。librarian 報告(--threads は実行時フラグ)。
  Acceptance criteria: `bend main.bend batch <100件ファイル> solve` の結果が逐次実行結果と一致(evidence 記録)。`bend PROOF.bend` 緑(L4 含む)。不正行はスキップされ index が詰まらない。**全4モード(solve/check/count/rate)で並列/逐次同値性・入力順保持**、件数 0/1/3/5/100 で Empty 充填による余分出力や順序変化なし、途中 fuel/不正行で後続ジョブが失われない(行単位結果が識別可能)。
  QA scenarios: happy — 100 件 generate → batch solve → 逐次結果と diff なし(evidence: task-14-batch.log)。failure — 81 文字でない行を含むファイルでエラー行が報告され処理継続する(evidence: task-14-badline.log)。
  Commit: Y | feat(cli): parallel batch processing over balanced tree
  Recommended task executor category: unspecified-high — 並列呼び出し契約と結果順序復元の実装。

- [ ] 15. bench + スケーリング測定(Wave 6)
  What to do: CLI `bench <file> [--generate N]`: `IO.now` 計時で N ∈ {1,10,100,1000,10000} の solve(batch パス利用)を測り、`N=<n> mode=cpu threads=runtime total_ms=<ms> per_ms=<ms>` 行を出力。N=1000 の中央値が 60 秒を超える場合は 10000 を `skipped` 行として記録(判定は threads ごと)。計測は**入力準備後に開始し、全batch結果を回収してから終了**する。比較用コーパスは seed/生成設定/ファイル内容ハッシュで固定し、threads 間で同一入力を使用。各 N は全て Solved で妥当性/元clue維持を満たすことが成功値; 失敗は時間表に混ぜず件数・状態を記録し、fuel 不足の測定は正常な solve ベンチにしない。測定手順: ネイティブバイナリを `--threads 1 / 8 / 16` で各3回、中央値を .omo/evidence/task-15-bench.md に表で記録(生3回値と中央値、成功/失敗/skip 理由を追跡); compiler/version・build・実threads・CPU・fuel・反復(3回・warm-up)も記録。todo 1 の判定が gpu-ok の場合のみ同一手順の GPU(`!` 経路)比較を evidence に追加、gpu-unavailable なら Skip と根拠を記録(CLI に --gpu フラグは作らない)。
  Must NOT do: GPU 非対応環境での GPU ベンチ強行。単一盤探索の GPU 実験(計画の Must NOT)。
  Parallelization: Wave 6 | Blocked by: 8,12,13,14 | Blocks: 16 | Can parallelize with: なし
  References: spec Benchmark 節(1→10000 のスケーリング、CPU/GPU)。bend guide Tooling 節(--threads/--gpu)。IO.now(librarian 報告: Nat 時計確認済み — 実機 /tmp/bend-base.txt)。
  Acceptance criteria: task-15-bench.md に threads 別中央値表とスケーリングの観察(線形でなくても良い、記録が目的)が残る。exit code 0。
  QA scenarios: happy — 2つの別々の入力形を実機実行: (a) `bend main.bend bench fixtures/easy/easy.txt`(file 入力、その fixture を N 回解く計時)と (b) `bend main.bend bench --generate 100`(generate 入力)。file と --generate の同時指定は exit 1(evidence: task-15-bench.log)。failure — 存在しないファイル指定で usage/エラー exit 1(evidence: task-15-badfile.log)。
  Commit: Y | feat(cli): benchmark command and scaling measurement
  Recommended task executor category: unspecified-high — 計時・複数実行の測定プロトコル実装。

- [ ] 16. 全体グリーン + クリーンアップ(Wave 6)
  What to do: 最終ゲート一括実行: `bend main.bend --checkup`(全 import 単独 check)、`bend PROOF.bend`(All terms check.、?TODO 0)、`bend qa/run.bend`(全 PASS)、7コマンド全部の fixture スモーク(solve/check/count/generate/rate/batch/bench)。tree 内に `@unsafe` と `?TODO` が無いことを grep で確認。fixtures の .expected が検証済み実行結果で backfill 済み(todo 10/13)であることを確認。tmp プローブの残置なし。git status クリーン、未コミット無し。
  Must NOT do: 失敗するゲートを無視して完了宣告。
  Parallelization: Wave 6 | Blocked by: 1..15 全て | Blocks: F1..F4
  References: 本計画の全ゲート定義。
  Acceptance criteria: 全ゲート緑の evidence セット(.omo/evidence/task-16-*.log)。
  QA scenarios: happy — 全ゲート実行ログ。failure — どれか1つでも赤なら修正して再実行(赤のまま完了にしない)。
  Commit: Y | chore(qa): full suite green and cleanup
  Recommended task executor category: quick — 機械的なゲート一括実行。

## Final verification wave
> Runs in parallel after ALL todos. ALL must APPROVE. Surface results and wait for the user's explicit okay before declaring complete.
- [ ] F1. Plan compliance audit
  Acceptance criteria: Success criteria 1〜6 を順に再検証し、各 Evidence パスを突き合わせて報告する。未達が1つでもあれば APPROVE しない。
- [ ] F2. Code quality review
  Acceptance criteria: 全 .bend ファイルの LSP/コンパイラ diagnostics がエラー0、@unsafe と ?TODO が 0(grep で確認)、終端検査・アフィン規約(plan 規約準拠)を spot check して報告。
- [ ] F3. Real CLI smoke (agent-executed)
  Acceptance criteria: 7コマンド全てを実機(argv 入力、JS レーン + ネイティブバイナリ両方)でスモークし、**コマンド別の .expected ファイルと照合**(solve=.solve.expected の 81 文字解、check=.check.expected、count=.count.expected、rate=.rate.expected、generate=2回実行の一致、batch=行毎の結果トークン、bench=計時行の出力のみ確認で値は照合しない)、出力を .omo/evidence/f3-smoke.log に保存。全 exit code 契約どおりで APPROVE。
- [ ] F4. Scope fidelity
  Acceptance criteria: 実装 diff が spec の 7 コマンド・generator オプション(seed/clues/count/difficulty/symmetry/minimal)・law 段階・batch 並列・bench に写像し、Must NOT have(GUI、@unsafe、高度手筋、単一盤 GPU 探索、README 等の過程資料)の違反が 0 であることを確認。

## Commit strategy
- リポジトリは空からの `git init`(todo 1)。コミット規約: Conventional Commits(`<type>(<scope>): <imperative>`)。履歴が無いため既定規約を採用。
- todo 毎に 1 コミット(ゲート緑のときのみ)。型: feat(sudoku)/feat(cli)/test(laws)/chore(repo|fixtures|qa)。
- WIP コミットを最終ブランチ(main)に残さない。ベンチの evidence は .omo/evidence/ 配下だが .gitignore は bin/ のみ(evidence はコミット対象)。

## Success criteria
1. `bend main.bend solve/check/count/generate/rate/batch/bench` の 7 コマンドが実機(argv 入力)で動き、終了コード契約(0/1/2/3/4)に従う。
2. `bend PROOF.bend` が `All terms check.`(?TODO 0、@unsafe 0)。
3. `bend qa/run.bend` が全 fixture・全 property で PASS(0 FAIL)。
4. `generate --seed N` が再現性を持ち、出力は全て一意解、`--symmetry` で対称、`--minimal` で minimal。
5. batch が逐次実行と同一結果で 100 件以上を並列処理し、threads 1/8/16 のスケーリングが記録される。
6. 全 todo の QA evidence が .omo/evidence/ に残り、クリーンアップ受領書付き。

