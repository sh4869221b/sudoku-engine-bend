# mainへの公開と証拠の配置

2026-10-03の最終成果を、ユーザーの指示によりmainへ公開するための記録。
本番コード、QA、固定入力、再現スクリプト、集計JSONと結果レポートを収録する。
追加の生測定データ（raw gzip）、候補の全コンソール出力、未採用案のpatch・診断dumpは
リポジトリへの公開対象から除き、納品済みの完全アーカイブに保持した。
既存mainに元からある証拠・固定corpusは削除していない。

完全アーカイブ名: `sudoku-engine-bend-cloud-final-20261003.tar.gz`
SHA256: `4b82b1fe5ca8d6ea1f886e42be505c361ab0064e6ee0020753f1b7d417aa3837`
分割配布は `.part01`、`.part02`、`.part03` と `README-join.txt`。
完全アーカイブには全raw観測、候補patch、履歴bundle、commit-map.json、同じ最終ソースがある。
既存レポート中の「rawを保存」「pushなし」「ローカルのみ」、過去commit IDとbundleの記述は、
18:39 UTCに完了した公開前アーカイブ時点の記録として読む。現在の公開範囲はこの文書が優先する。
過去実験の完全再計算にはそのアーカイブが必要で、集計JSONだけからrawを再構成できるとは主張しない。

## 検証と再現

通常の利用はREADMEの固定toolchain setup、build、verify手順でよい。
最終検証時の139個の本番/QA/fixture入力はハッシュで同一と確認した。
主指標は固定35ケース・2ブロック各21組を全統合した3.9686倍（95% CI3.9399–4.0073）。
5倍未達、局所的な速度・メモリ退行、有限oracleの制約は [REPORT.md](REPORT.md) を参照。

[final_validate.py](final_validate.py) は新しい空の --out へ実行する。
--base は343bf98から、--reference52 は完全アーカイブのperf/cloud-52から、
同一の固定toolchainでビルドした実行ファイルを指定する。
--corpora は完全アーカイブのcorpora、またはqa/perf-20261001の固定corpus復元手順を使用する。
既存results/finalは過去集計であり、除外したrawファイルはアーカイブから入手する。

公開準備時は通常verifyがQAのnativeコンパイルで2回exit137となったため、
BendのC出力とClangの実行を順に分離して全ゲートを完了した。
ソース・toolchain・コンパイラflagsは変更せず、出力CとQA実行ファイルのハッシュ一致も確認した。
詳しくは [PUBLICATION-VERIFICATION.md](PUBLICATION-VERIFICATION.md)。
