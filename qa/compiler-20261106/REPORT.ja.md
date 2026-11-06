# Bend 2.0.40 対応とベンチマーク比較

対象: sh4869221b/sudoku-engine-bend。基準main: `42ed83aeb51c502d15d57e10088a8e3a7d830c4e`。

公式stable 2.0.40（2026-11-06 02:06:29 UTC公開）へlockを更新しました。
ソースcommit・公式archive・binary・kernel sourceをSHA-256で固定しています。
Lean 4.34.1とClang 19.1.7は維持し、新しい未改変BendTTを構築しました。

本変更は実行時の引数形式変更に対応する実装、QA、低メモリアダプター、回帰テスト、CI、ドキュメントを含みます。Sudokuのアルゴリズムとproof本体は維持しています。

進行状況: Python回帰44件、kernel harness回帰12件、JS harness回帰12件とネイティブビルドは成功。両版の独立kernel verdictも成功。全体QAと比較計測は実行中です。完了後にこの報告と `results/` を更新します。現段階では性能改善や全gate成功を主張しません。

手順は [README.md](README.md)、互換性の調査は [UPSTREAM-REVIEW.md](UPSTREAM-REVIEW.md)、公式release確認は [release.json](release.json) を参照してください。
