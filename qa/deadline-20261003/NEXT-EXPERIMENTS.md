> 公開版では追加raw観測・候補dumpを除外しています。完全な証拠と過去履歴は納品済みアーカイブに保持されています。 [公開範囲](../cloud-20261003/PUBLICATION.md)を参照。

Ongoing notes14:15UTC; not an outcome. Deadline19:00UTC, final QA18:30UTC.

32 exact MRV lowerbound:Q.select only scans when all urgent(0/1) flags zero,
so stop at first count2. Random arbitrary-domain oracle is staged /tmp/queued-qa32.bend.
33 one-copy physical lines: /tmp/line_split33.py and /tmp/line-split33-qa.bend;
retain old text_scan asoracle; full file_differential.py and100000char lines.
34 tail-aware batch solved-board output: addB.show_tail (show_go base tail),
C.batch_solve_tail parser/error/solve cases matching C.eval mode1,batchTrue;
B.job_line mode1 uses newtail renderer, modes2/3/4 existing C.eval+suffix.
Keep public C.eval/replies/show unchanged; strict String.eq proof tests wide digits.
31 coarsebench group4 prototype /tmp/group_bench31.py; measured, pendingdecision.

35 prospective bit-sliced candidate supports: same API encode/decode/select/place
asQ, F.import aliasQ pointsnewmodule, preservesfirstguessactivation/snapshots/fuel.
ActiveArray256 rawdigits0..80, supports128+(d-1)*3+block, countsbitplanes155..166
(ones155+block,twos158,fours161,eights164), empty167..169, urgency170..172,
doubles173..175. Encode sourcecachedArray128 and newArray256 (old occupancy cannot
be overwritten); initialize81cells, add each present digit support bit, bitplanes
from C.mask_count, empty/urgent/doubles. decode copies81rawdigits toArray128.
Native peer mask table81 entries asData{low,mid,high}, same20uniquepeers.
Place setsrawdigit, clearsselectedEmpty andUrgent(forforced)/Double(selectedguess2
orpossibleNSnotdouble; clearalwayssafe). For each3block: targets=SupportD &Peers &Empty.
Ifzero skip. Readoldones/twos/fours, clearSupportDtargets, XORones withtargets,
borrow1=targets &~oldones; XORtwoswithborrow1; borrow2=borrow1&~oldtwos;
XORfourswithborrow2; borrow3=borrow2&~oldfours; onlyget/XOReightsifborrow3nonzero.
Eachpeer decrement removesexactlyone candidate. changeDouble=targets &oldtwos &~oldfours
(count2or3; count10/11 impossible); XORcachedDouble bychangeDouble.
newSingles=changeDouble &~oldones; ORUrgent(newSingles). count1→0 alreadyurgent.
Selecturgency lowestphysicalposition first (0and1mixed), elseDouble lowestpos;
else read12planes+3empties once and derive bitmask for counts3..9, choosefirstpos
ofsmallestcount. Selectedcandidate mask reads9supports atblock+posbit.
No allocation/recursion flags metadata precision assumptions outside valid search.
QAbitsets vsindependent C.cache rawboard at eachSearching; all27support wordmasks,
12planes/3empty/3urgent/3double bits, exactChoice,32trailingindices; then1931/6060,
all gates and35paired suites. NevercallselectonstaleBacktracking metadata; nextguess
snapshotrestore before any forward selection. Costs: initmorewrites/clones1KB vs512;
bulkplace3functioncalls vs20peer calls; measure before adoption. No count cap.
