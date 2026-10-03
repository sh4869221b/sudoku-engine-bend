import Base
import ./arithmetic.bend as M
import ./board.bend as B

def used_go(n: Nat, +unit: U32, +j: U32, r: Array<U32> & U32, used: U32) -> Array<U32> & U32:
  match n:
    case 0n:
      (Pair.fst(Array<U32>, U32, r), used)
    case 1n+k:
      (b, d) = r
      used_go(k, unit, (j + 1 : U32), Array.get(U32, b, B.unit_pos(unit, (j + 1 : U32))), U32.or(used, B.bit(d)))

def unit_used(b: Array<U32>, +unit: U32) -> Array<U32> & U32:
  used_go(9n, unit, 0, Array.get(U32, b, B.unit_pos(unit, 0)), 0)

def add_unit(+unit: U32, r: Array<U32> & U32) -> Array<U32> & U32:
  (b, used) = r
  used_go(9n, unit, 0, Array.get(U32, b, B.unit_pos(unit, 0)), used)

def invert(r: Array<U32> & U32) -> Array<U32> & U32:
  (b, used) = r
  (b, U32.and(1022, U32.not(used)))

def at(b: Array<U32>, +p: U32) -> Array<U32> & U32:
  invert(add_unit((18 + B.box_of(p) : U32), add_unit((9 + M.rem9(p) : U32), unit_used(b, (M.div9(p) : U32)))))

def pop(n: Nat, +mask: U32, acc: U32) -> U32:
  match n:
    case 0n:
      acc
    case 1n+k:
      pop(k, U32.shr(mask), (acc + U32.and(mask, 1) : U32))

# Dense low-ten-bit cardinality table; all upper bits remain ignored.
def count_index(index: U32) -> U32:
  match index:
    case 0:
      0
    case 1:
      1
    case 2:
      1
    case 3:
      2
    case 4:
      1
    case 5:
      2
    case 6:
      2
    case 7:
      3
    case 8:
      1
    case 9:
      2
    case 10:
      2
    case 11:
      3
    case 12:
      2
    case 13:
      3
    case 14:
      3
    case 15:
      4
    case 16:
      1
    case 17:
      2
    case 18:
      2
    case 19:
      3
    case 20:
      2
    case 21:
      3
    case 22:
      3
    case 23:
      4
    case 24:
      2
    case 25:
      3
    case 26:
      3
    case 27:
      4
    case 28:
      3
    case 29:
      4
    case 30:
      4
    case 31:
      5
    case 32:
      1
    case 33:
      2
    case 34:
      2
    case 35:
      3
    case 36:
      2
    case 37:
      3
    case 38:
      3
    case 39:
      4
    case 40:
      2
    case 41:
      3
    case 42:
      3
    case 43:
      4
    case 44:
      3
    case 45:
      4
    case 46:
      4
    case 47:
      5
    case 48:
      2
    case 49:
      3
    case 50:
      3
    case 51:
      4
    case 52:
      3
    case 53:
      4
    case 54:
      4
    case 55:
      5
    case 56:
      3
    case 57:
      4
    case 58:
      4
    case 59:
      5
    case 60:
      4
    case 61:
      5
    case 62:
      5
    case 63:
      6
    case 64:
      1
    case 65:
      2
    case 66:
      2
    case 67:
      3
    case 68:
      2
    case 69:
      3
    case 70:
      3
    case 71:
      4
    case 72:
      2
    case 73:
      3
    case 74:
      3
    case 75:
      4
    case 76:
      3
    case 77:
      4
    case 78:
      4
    case 79:
      5
    case 80:
      2
    case 81:
      3
    case 82:
      3
    case 83:
      4
    case 84:
      3
    case 85:
      4
    case 86:
      4
    case 87:
      5
    case 88:
      3
    case 89:
      4
    case 90:
      4
    case 91:
      5
    case 92:
      4
    case 93:
      5
    case 94:
      5
    case 95:
      6
    case 96:
      2
    case 97:
      3
    case 98:
      3
    case 99:
      4
    case 100:
      3
    case 101:
      4
    case 102:
      4
    case 103:
      5
    case 104:
      3
    case 105:
      4
    case 106:
      4
    case 107:
      5
    case 108:
      4
    case 109:
      5
    case 110:
      5
    case 111:
      6
    case 112:
      3
    case 113:
      4
    case 114:
      4
    case 115:
      5
    case 116:
      4
    case 117:
      5
    case 118:
      5
    case 119:
      6
    case 120:
      4
    case 121:
      5
    case 122:
      5
    case 123:
      6
    case 124:
      5
    case 125:
      6
    case 126:
      6
    case 127:
      7
    case 128:
      1
    case 129:
      2
    case 130:
      2
    case 131:
      3
    case 132:
      2
    case 133:
      3
    case 134:
      3
    case 135:
      4
    case 136:
      2
    case 137:
      3
    case 138:
      3
    case 139:
      4
    case 140:
      3
    case 141:
      4
    case 142:
      4
    case 143:
      5
    case 144:
      2
    case 145:
      3
    case 146:
      3
    case 147:
      4
    case 148:
      3
    case 149:
      4
    case 150:
      4
    case 151:
      5
    case 152:
      3
    case 153:
      4
    case 154:
      4
    case 155:
      5
    case 156:
      4
    case 157:
      5
    case 158:
      5
    case 159:
      6
    case 160:
      2
    case 161:
      3
    case 162:
      3
    case 163:
      4
    case 164:
      3
    case 165:
      4
    case 166:
      4
    case 167:
      5
    case 168:
      3
    case 169:
      4
    case 170:
      4
    case 171:
      5
    case 172:
      4
    case 173:
      5
    case 174:
      5
    case 175:
      6
    case 176:
      3
    case 177:
      4
    case 178:
      4
    case 179:
      5
    case 180:
      4
    case 181:
      5
    case 182:
      5
    case 183:
      6
    case 184:
      4
    case 185:
      5
    case 186:
      5
    case 187:
      6
    case 188:
      5
    case 189:
      6
    case 190:
      6
    case 191:
      7
    case 192:
      2
    case 193:
      3
    case 194:
      3
    case 195:
      4
    case 196:
      3
    case 197:
      4
    case 198:
      4
    case 199:
      5
    case 200:
      3
    case 201:
      4
    case 202:
      4
    case 203:
      5
    case 204:
      4
    case 205:
      5
    case 206:
      5
    case 207:
      6
    case 208:
      3
    case 209:
      4
    case 210:
      4
    case 211:
      5
    case 212:
      4
    case 213:
      5
    case 214:
      5
    case 215:
      6
    case 216:
      4
    case 217:
      5
    case 218:
      5
    case 219:
      6
    case 220:
      5
    case 221:
      6
    case 222:
      6
    case 223:
      7
    case 224:
      3
    case 225:
      4
    case 226:
      4
    case 227:
      5
    case 228:
      4
    case 229:
      5
    case 230:
      5
    case 231:
      6
    case 232:
      4
    case 233:
      5
    case 234:
      5
    case 235:
      6
    case 236:
      5
    case 237:
      6
    case 238:
      6
    case 239:
      7
    case 240:
      4
    case 241:
      5
    case 242:
      5
    case 243:
      6
    case 244:
      5
    case 245:
      6
    case 246:
      6
    case 247:
      7
    case 248:
      5
    case 249:
      6
    case 250:
      6
    case 251:
      7
    case 252:
      6
    case 253:
      7
    case 254:
      7
    case 255:
      8
    case 256:
      1
    case 257:
      2
    case 258:
      2
    case 259:
      3
    case 260:
      2
    case 261:
      3
    case 262:
      3
    case 263:
      4
    case 264:
      2
    case 265:
      3
    case 266:
      3
    case 267:
      4
    case 268:
      3
    case 269:
      4
    case 270:
      4
    case 271:
      5
    case 272:
      2
    case 273:
      3
    case 274:
      3
    case 275:
      4
    case 276:
      3
    case 277:
      4
    case 278:
      4
    case 279:
      5
    case 280:
      3
    case 281:
      4
    case 282:
      4
    case 283:
      5
    case 284:
      4
    case 285:
      5
    case 286:
      5
    case 287:
      6
    case 288:
      2
    case 289:
      3
    case 290:
      3
    case 291:
      4
    case 292:
      3
    case 293:
      4
    case 294:
      4
    case 295:
      5
    case 296:
      3
    case 297:
      4
    case 298:
      4
    case 299:
      5
    case 300:
      4
    case 301:
      5
    case 302:
      5
    case 303:
      6
    case 304:
      3
    case 305:
      4
    case 306:
      4
    case 307:
      5
    case 308:
      4
    case 309:
      5
    case 310:
      5
    case 311:
      6
    case 312:
      4
    case 313:
      5
    case 314:
      5
    case 315:
      6
    case 316:
      5
    case 317:
      6
    case 318:
      6
    case 319:
      7
    case 320:
      2
    case 321:
      3
    case 322:
      3
    case 323:
      4
    case 324:
      3
    case 325:
      4
    case 326:
      4
    case 327:
      5
    case 328:
      3
    case 329:
      4
    case 330:
      4
    case 331:
      5
    case 332:
      4
    case 333:
      5
    case 334:
      5
    case 335:
      6
    case 336:
      3
    case 337:
      4
    case 338:
      4
    case 339:
      5
    case 340:
      4
    case 341:
      5
    case 342:
      5
    case 343:
      6
    case 344:
      4
    case 345:
      5
    case 346:
      5
    case 347:
      6
    case 348:
      5
    case 349:
      6
    case 350:
      6
    case 351:
      7
    case 352:
      3
    case 353:
      4
    case 354:
      4
    case 355:
      5
    case 356:
      4
    case 357:
      5
    case 358:
      5
    case 359:
      6
    case 360:
      4
    case 361:
      5
    case 362:
      5
    case 363:
      6
    case 364:
      5
    case 365:
      6
    case 366:
      6
    case 367:
      7
    case 368:
      4
    case 369:
      5
    case 370:
      5
    case 371:
      6
    case 372:
      5
    case 373:
      6
    case 374:
      6
    case 375:
      7
    case 376:
      5
    case 377:
      6
    case 378:
      6
    case 379:
      7
    case 380:
      6
    case 381:
      7
    case 382:
      7
    case 383:
      8
    case 384:
      2
    case 385:
      3
    case 386:
      3
    case 387:
      4
    case 388:
      3
    case 389:
      4
    case 390:
      4
    case 391:
      5
    case 392:
      3
    case 393:
      4
    case 394:
      4
    case 395:
      5
    case 396:
      4
    case 397:
      5
    case 398:
      5
    case 399:
      6
    case 400:
      3
    case 401:
      4
    case 402:
      4
    case 403:
      5
    case 404:
      4
    case 405:
      5
    case 406:
      5
    case 407:
      6
    case 408:
      4
    case 409:
      5
    case 410:
      5
    case 411:
      6
    case 412:
      5
    case 413:
      6
    case 414:
      6
    case 415:
      7
    case 416:
      3
    case 417:
      4
    case 418:
      4
    case 419:
      5
    case 420:
      4
    case 421:
      5
    case 422:
      5
    case 423:
      6
    case 424:
      4
    case 425:
      5
    case 426:
      5
    case 427:
      6
    case 428:
      5
    case 429:
      6
    case 430:
      6
    case 431:
      7
    case 432:
      4
    case 433:
      5
    case 434:
      5
    case 435:
      6
    case 436:
      5
    case 437:
      6
    case 438:
      6
    case 439:
      7
    case 440:
      5
    case 441:
      6
    case 442:
      6
    case 443:
      7
    case 444:
      6
    case 445:
      7
    case 446:
      7
    case 447:
      8
    case 448:
      3
    case 449:
      4
    case 450:
      4
    case 451:
      5
    case 452:
      4
    case 453:
      5
    case 454:
      5
    case 455:
      6
    case 456:
      4
    case 457:
      5
    case 458:
      5
    case 459:
      6
    case 460:
      5
    case 461:
      6
    case 462:
      6
    case 463:
      7
    case 464:
      4
    case 465:
      5
    case 466:
      5
    case 467:
      6
    case 468:
      5
    case 469:
      6
    case 470:
      6
    case 471:
      7
    case 472:
      5
    case 473:
      6
    case 474:
      6
    case 475:
      7
    case 476:
      6
    case 477:
      7
    case 478:
      7
    case 479:
      8
    case 480:
      4
    case 481:
      5
    case 482:
      5
    case 483:
      6
    case 484:
      5
    case 485:
      6
    case 486:
      6
    case 487:
      7
    case 488:
      5
    case 489:
      6
    case 490:
      6
    case 491:
      7
    case 492:
      6
    case 493:
      7
    case 494:
      7
    case 495:
      8
    case 496:
      5
    case 497:
      6
    case 498:
      6
    case 499:
      7
    case 500:
      6
    case 501:
      7
    case 502:
      7
    case 503:
      8
    case 504:
      6
    case 505:
      7
    case 506:
      7
    case 507:
      8
    case 508:
      7
    case 509:
      8
    case 510:
      8
    case 511:
      9
    case 512:
      1
    case 513:
      2
    case 514:
      2
    case 515:
      3
    case 516:
      2
    case 517:
      3
    case 518:
      3
    case 519:
      4
    case 520:
      2
    case 521:
      3
    case 522:
      3
    case 523:
      4
    case 524:
      3
    case 525:
      4
    case 526:
      4
    case 527:
      5
    case 528:
      2
    case 529:
      3
    case 530:
      3
    case 531:
      4
    case 532:
      3
    case 533:
      4
    case 534:
      4
    case 535:
      5
    case 536:
      3
    case 537:
      4
    case 538:
      4
    case 539:
      5
    case 540:
      4
    case 541:
      5
    case 542:
      5
    case 543:
      6
    case 544:
      2
    case 545:
      3
    case 546:
      3
    case 547:
      4
    case 548:
      3
    case 549:
      4
    case 550:
      4
    case 551:
      5
    case 552:
      3
    case 553:
      4
    case 554:
      4
    case 555:
      5
    case 556:
      4
    case 557:
      5
    case 558:
      5
    case 559:
      6
    case 560:
      3
    case 561:
      4
    case 562:
      4
    case 563:
      5
    case 564:
      4
    case 565:
      5
    case 566:
      5
    case 567:
      6
    case 568:
      4
    case 569:
      5
    case 570:
      5
    case 571:
      6
    case 572:
      5
    case 573:
      6
    case 574:
      6
    case 575:
      7
    case 576:
      2
    case 577:
      3
    case 578:
      3
    case 579:
      4
    case 580:
      3
    case 581:
      4
    case 582:
      4
    case 583:
      5
    case 584:
      3
    case 585:
      4
    case 586:
      4
    case 587:
      5
    case 588:
      4
    case 589:
      5
    case 590:
      5
    case 591:
      6
    case 592:
      3
    case 593:
      4
    case 594:
      4
    case 595:
      5
    case 596:
      4
    case 597:
      5
    case 598:
      5
    case 599:
      6
    case 600:
      4
    case 601:
      5
    case 602:
      5
    case 603:
      6
    case 604:
      5
    case 605:
      6
    case 606:
      6
    case 607:
      7
    case 608:
      3
    case 609:
      4
    case 610:
      4
    case 611:
      5
    case 612:
      4
    case 613:
      5
    case 614:
      5
    case 615:
      6
    case 616:
      4
    case 617:
      5
    case 618:
      5
    case 619:
      6
    case 620:
      5
    case 621:
      6
    case 622:
      6
    case 623:
      7
    case 624:
      4
    case 625:
      5
    case 626:
      5
    case 627:
      6
    case 628:
      5
    case 629:
      6
    case 630:
      6
    case 631:
      7
    case 632:
      5
    case 633:
      6
    case 634:
      6
    case 635:
      7
    case 636:
      6
    case 637:
      7
    case 638:
      7
    case 639:
      8
    case 640:
      2
    case 641:
      3
    case 642:
      3
    case 643:
      4
    case 644:
      3
    case 645:
      4
    case 646:
      4
    case 647:
      5
    case 648:
      3
    case 649:
      4
    case 650:
      4
    case 651:
      5
    case 652:
      4
    case 653:
      5
    case 654:
      5
    case 655:
      6
    case 656:
      3
    case 657:
      4
    case 658:
      4
    case 659:
      5
    case 660:
      4
    case 661:
      5
    case 662:
      5
    case 663:
      6
    case 664:
      4
    case 665:
      5
    case 666:
      5
    case 667:
      6
    case 668:
      5
    case 669:
      6
    case 670:
      6
    case 671:
      7
    case 672:
      3
    case 673:
      4
    case 674:
      4
    case 675:
      5
    case 676:
      4
    case 677:
      5
    case 678:
      5
    case 679:
      6
    case 680:
      4
    case 681:
      5
    case 682:
      5
    case 683:
      6
    case 684:
      5
    case 685:
      6
    case 686:
      6
    case 687:
      7
    case 688:
      4
    case 689:
      5
    case 690:
      5
    case 691:
      6
    case 692:
      5
    case 693:
      6
    case 694:
      6
    case 695:
      7
    case 696:
      5
    case 697:
      6
    case 698:
      6
    case 699:
      7
    case 700:
      6
    case 701:
      7
    case 702:
      7
    case 703:
      8
    case 704:
      3
    case 705:
      4
    case 706:
      4
    case 707:
      5
    case 708:
      4
    case 709:
      5
    case 710:
      5
    case 711:
      6
    case 712:
      4
    case 713:
      5
    case 714:
      5
    case 715:
      6
    case 716:
      5
    case 717:
      6
    case 718:
      6
    case 719:
      7
    case 720:
      4
    case 721:
      5
    case 722:
      5
    case 723:
      6
    case 724:
      5
    case 725:
      6
    case 726:
      6
    case 727:
      7
    case 728:
      5
    case 729:
      6
    case 730:
      6
    case 731:
      7
    case 732:
      6
    case 733:
      7
    case 734:
      7
    case 735:
      8
    case 736:
      4
    case 737:
      5
    case 738:
      5
    case 739:
      6
    case 740:
      5
    case 741:
      6
    case 742:
      6
    case 743:
      7
    case 744:
      5
    case 745:
      6
    case 746:
      6
    case 747:
      7
    case 748:
      6
    case 749:
      7
    case 750:
      7
    case 751:
      8
    case 752:
      5
    case 753:
      6
    case 754:
      6
    case 755:
      7
    case 756:
      6
    case 757:
      7
    case 758:
      7
    case 759:
      8
    case 760:
      6
    case 761:
      7
    case 762:
      7
    case 763:
      8
    case 764:
      7
    case 765:
      8
    case 766:
      8
    case 767:
      9
    case 768:
      2
    case 769:
      3
    case 770:
      3
    case 771:
      4
    case 772:
      3
    case 773:
      4
    case 774:
      4
    case 775:
      5
    case 776:
      3
    case 777:
      4
    case 778:
      4
    case 779:
      5
    case 780:
      4
    case 781:
      5
    case 782:
      5
    case 783:
      6
    case 784:
      3
    case 785:
      4
    case 786:
      4
    case 787:
      5
    case 788:
      4
    case 789:
      5
    case 790:
      5
    case 791:
      6
    case 792:
      4
    case 793:
      5
    case 794:
      5
    case 795:
      6
    case 796:
      5
    case 797:
      6
    case 798:
      6
    case 799:
      7
    case 800:
      3
    case 801:
      4
    case 802:
      4
    case 803:
      5
    case 804:
      4
    case 805:
      5
    case 806:
      5
    case 807:
      6
    case 808:
      4
    case 809:
      5
    case 810:
      5
    case 811:
      6
    case 812:
      5
    case 813:
      6
    case 814:
      6
    case 815:
      7
    case 816:
      4
    case 817:
      5
    case 818:
      5
    case 819:
      6
    case 820:
      5
    case 821:
      6
    case 822:
      6
    case 823:
      7
    case 824:
      5
    case 825:
      6
    case 826:
      6
    case 827:
      7
    case 828:
      6
    case 829:
      7
    case 830:
      7
    case 831:
      8
    case 832:
      3
    case 833:
      4
    case 834:
      4
    case 835:
      5
    case 836:
      4
    case 837:
      5
    case 838:
      5
    case 839:
      6
    case 840:
      4
    case 841:
      5
    case 842:
      5
    case 843:
      6
    case 844:
      5
    case 845:
      6
    case 846:
      6
    case 847:
      7
    case 848:
      4
    case 849:
      5
    case 850:
      5
    case 851:
      6
    case 852:
      5
    case 853:
      6
    case 854:
      6
    case 855:
      7
    case 856:
      5
    case 857:
      6
    case 858:
      6
    case 859:
      7
    case 860:
      6
    case 861:
      7
    case 862:
      7
    case 863:
      8
    case 864:
      4
    case 865:
      5
    case 866:
      5
    case 867:
      6
    case 868:
      5
    case 869:
      6
    case 870:
      6
    case 871:
      7
    case 872:
      5
    case 873:
      6
    case 874:
      6
    case 875:
      7
    case 876:
      6
    case 877:
      7
    case 878:
      7
    case 879:
      8
    case 880:
      5
    case 881:
      6
    case 882:
      6
    case 883:
      7
    case 884:
      6
    case 885:
      7
    case 886:
      7
    case 887:
      8
    case 888:
      6
    case 889:
      7
    case 890:
      7
    case 891:
      8
    case 892:
      7
    case 893:
      8
    case 894:
      8
    case 895:
      9
    case 896:
      3
    case 897:
      4
    case 898:
      4
    case 899:
      5
    case 900:
      4
    case 901:
      5
    case 902:
      5
    case 903:
      6
    case 904:
      4
    case 905:
      5
    case 906:
      5
    case 907:
      6
    case 908:
      5
    case 909:
      6
    case 910:
      6
    case 911:
      7
    case 912:
      4
    case 913:
      5
    case 914:
      5
    case 915:
      6
    case 916:
      5
    case 917:
      6
    case 918:
      6
    case 919:
      7
    case 920:
      5
    case 921:
      6
    case 922:
      6
    case 923:
      7
    case 924:
      6
    case 925:
      7
    case 926:
      7
    case 927:
      8
    case 928:
      4
    case 929:
      5
    case 930:
      5
    case 931:
      6
    case 932:
      5
    case 933:
      6
    case 934:
      6
    case 935:
      7
    case 936:
      5
    case 937:
      6
    case 938:
      6
    case 939:
      7
    case 940:
      6
    case 941:
      7
    case 942:
      7
    case 943:
      8
    case 944:
      5
    case 945:
      6
    case 946:
      6
    case 947:
      7
    case 948:
      6
    case 949:
      7
    case 950:
      7
    case 951:
      8
    case 952:
      6
    case 953:
      7
    case 954:
      7
    case 955:
      8
    case 956:
      7
    case 957:
      8
    case 958:
      8
    case 959:
      9
    case 960:
      4
    case 961:
      5
    case 962:
      5
    case 963:
      6
    case 964:
      5
    case 965:
      6
    case 966:
      6
    case 967:
      7
    case 968:
      5
    case 969:
      6
    case 970:
      6
    case 971:
      7
    case 972:
      6
    case 973:
      7
    case 974:
      7
    case 975:
      8
    case 976:
      5
    case 977:
      6
    case 978:
      6
    case 979:
      7
    case 980:
      6
    case 981:
      7
    case 982:
      7
    case 983:
      8
    case 984:
      6
    case 985:
      7
    case 986:
      7
    case 987:
      8
    case 988:
      7
    case 989:
      8
    case 990:
      8
    case 991:
      9
    case 992:
      5
    case 993:
      6
    case 994:
      6
    case 995:
      7
    case 996:
      6
    case 997:
      7
    case 998:
      7
    case 999:
      8
    case 1000:
      6
    case 1001:
      7
    case 1002:
      7
    case 1003:
      8
    case 1004:
      7
    case 1005:
      8
    case 1006:
      8
    case 1007:
      9
    case 1008:
      6
    case 1009:
      7
    case 1010:
      7
    case 1011:
      8
    case 1012:
      7
    case 1013:
      8
    case 1014:
      8
    case 1015:
      9
    case 1016:
      7
    case 1017:
      8
    case 1018:
      8
    case 1019:
      9
    case 1020:
      8
    case 1021:
      9
    case 1022:
      9
    case 1023:
      10
    case _:
      0

def mask_count(mask: U32) -> U32:
  count_index(U32.and(mask, 1023))

def digits_go(n: Nat, +d: U32, +mask: U32) -> List<&2, U32>:
  match n:
    case 0n:
      Nil{}
    case 1n+k:
      List.append(&2, U32, Bool.pick(List<&2, U32>, U32.is_ne(U32.and(mask, B.bit(d)), 0), [d], Nil{}), digits_go(k, (d + 1 : U32), mask))


# Decode only present digits; retain ascending order and ignore bit0/upper bits.
def digits_bits(n: Nat, mask: U32) -> List<&2, U32>:
  match n mask:
    case _ 0:
      Nil{}
    case 0n _:
      Nil{}
    case 1n+k +bits:
      +bit = U32.and(bits, (0 - bits : U32))
      mask_count((bit - 1 : U32)) <> digits_bits(k, U32.xor(bits, bit))

def mask_digits(mask: U32) -> List<&2, U32>:
  digits_bits(9n, U32.and(mask, 1022))

type Choice is Data:
  Choice{pos: U32, mask: U32, size: U32}

def choose(+pos: U32, prior: Choice, r: Array<U32> & U32) -> Array<U32> & Choice:
  match prior:
    case Choice{oldpos, oldmask, +size}:
      (b, +mask) = r
      +n = mask_count(mask)
      (b, Bool.pick(Choice, (n < size : U32), Choice{pos, mask, n}, Choice{oldpos, oldmask, size}))

def inspect(+pos: U32, prior: Choice, r: Array<U32> & U32) -> Array<U32> & Choice:
  (b, d) = r
  match d:
    case 0:
      choose(pos, prior, at(b, pos))
    case _:
      (b, prior)

def select_go(n: Nat, +pos: U32, r: Array<U32> & Choice) -> Array<U32> & Choice:
  match n:
    case 0n:
      r
    case 1n+k:
      (b, choice) = r
      match choice:
        case Choice{p, m, 0}:
          (b, Choice{p, m, 0})
        case Choice{p, m, 1}:
          (b, Choice{p, m, 1})
        case Choice{p, m, size}:
          select_go(k, (pos + 1 : U32), inspect(pos, Choice{p, m, size}, Array.get(U32, b, pos)))

def select(b: Array<U32>) -> Array<U32> & Choice:
  select_go(81n, 0, (b, Choice{81, 0, 10}))

# Search-local unit occupancy occupies unused padding cells81..107. The public
# candidate API above remains valid for arbitrary uncached boards.
def cached_merge(used: U32, r: Array<U32> & U32) -> Array<U32> & U32:
  (b, next) = r
  (b, U32.or(used, next))

def cached_add(pos: U32, r: Array<U32> & U32) -> Array<U32> & U32:
  (b, used) = r
  cached_merge(used, Array.get(U32, b, pos))

def cached_at(b: Array<U32>, +p: U32) -> Array<U32> & U32:
  invert(cached_add((99 + B.box_of(p) : U32), cached_add((90 + M.rem9(p) : U32), Array.get(U32, b, (81 + M.div9(p) : U32)))))

def cached_inspect(+pos: U32, prior: Choice, r: Array<U32> & U32) -> Array<U32> & Choice:
  (b, d) = r
  match d:
    case 0:
      choose(pos, prior, cached_at(b, pos))
    case _:
      (b, prior)

def cached_select_go(n: Nat, +pos: U32, r: Array<U32> & Choice) -> Array<U32> & Choice:
  match n:
    case 0n:
      r
    case 1n+k:
      (b, choice) = r
      match choice:
        case Choice{p, m, 0}:
          (b, Choice{p, m, 0})
        case Choice{p, m, 1}:
          (b, Choice{p, m, 1})
        case Choice{p, m, size}:
          cached_select_go(k, (pos + 1 : U32), cached_inspect(pos, Choice{p, m, size}, Array.get(U32, b, pos)))

def cached_start(r: Array<U32> & U32) -> Array<U32> & Choice:
  (b, +start) = r
  cached_select_go(U32.to_nat((81 - start : U32)), start, (b, Choice{81, 0, 10}))

# Carry scalar MRV fields through the scan, allocating Choice only at exit.
def scalar_mask(+pos: U32, r: Array<U32> & U32) -> Array<U32> & U32:
  (b, d) = r
  match d:
    case 0:
      cached_at(b, pos)
    case _:
      (b, 2048)

def scalar_size(mask: U32) -> U32:
  match mask:
    case 2048:
      10
    case other:
      mask_count(other)

def scalar_advance(+pos: U32, +bestpos: U32, +bestmask: U32, +bestsize: U32, r: Array<U32> & U32) -> Array<U32> & U32 & U32 & U32:
  (b, +mask) = r
  +count = scalar_size(mask)
  +better = (count < bestsize : U32)
  (b, (Bool.pick(U32, better, pos, bestpos), (Bool.pick(U32, better, mask, bestmask), Bool.pick(U32, better, count, bestsize))))

def direct_advance(+pos: U32, +bestpos: U32, +bestmask: U32, +bestsize: U32, r: Array<U32> & U32) -> Array<U32> & U32 & U32 & U32:
  (b, d) = r
  match d:
    case 0:
      scalar_advance(pos, bestpos, bestmask, bestsize, cached_at(b, pos))
    case _:
      (b, (bestpos, (bestmask, bestsize)))

def scalar_select(n: Nat, +pos: U32, r: Array<U32> & U32 & U32 & U32) -> Array<U32> & Choice:
  match n r:
    case _ Tuple{b, Tuple{bestpos, Tuple{bestmask, 0}}}:
      (b, Choice{bestpos, bestmask, 0})
    case _ Tuple{b, Tuple{bestpos, Tuple{bestmask, 1}}}:
      (b, Choice{bestpos, bestmask, 1})
    case 0n Tuple{b, Tuple{bestpos, Tuple{bestmask, size}}}:
      (b, Choice{bestpos, bestmask, size})
    case 1n+k Tuple{b, Tuple{bestpos, Tuple{bestmask, size}}}:
      scalar_select(k, (pos + 1 : U32), direct_advance(pos, bestpos, bestmask, size, Array.get(U32, b, pos)))

def scalar_start(r: Array<U32> & U32) -> Array<U32> & Choice:
  (b, +start) = r
  scalar_select(U32.to_nat((81 - start : U32)), start, (b, (81, (0, 10))))

# Row occupancy keeps its original low-ten bits; bits10..18 mark empty columns.
# Selection reuses each row read, visits empties in exact physical order, and
# uses the dense count table to decode the selected bit within a nine-bit row.
type RowScan is Type:
  RowLive{board: Array<U32>, row: U32, bits: U32, used: U32, boxbase: U32, bestpos: U32, bestmask: U32, bestsize: U32}
  RowDone{board: Array<U32>, bestpos: U32, bestmask: U32, bestsize: U32}

def row_scan_open(open: Bool, +row: U32, p: U32, m: U32, size: U32, r: Array<U32> & U32) -> RowScan:
  match open:
    case False{}:
      (b, word) = r
      RowDone{b, p, m, size}
    case True{}:
      (b, +word) = r
      RowLive{b, row, U32.and(U32.shrn(word, 10n), 511), word, (99 + M.div3(row) * 3 : U32), p, m, size}

def row_scan_start(+row: U32, p: U32, m: U32, size: U32, r: Array<U32> & U32) -> RowScan:
  row_scan_open((row < 9 : U32), row, p, m, size, r)

def row_mask(b: Array<U32>, +col: U32, boxbase: U32, used: U32) -> Array<U32> & U32:
  invert(cached_add((boxbase + M.div3(col) : U32), cached_add((90 + col : U32), (b, used))))

def row_scan_result(urgent: Bool, row: U32, bits: U32, used: U32, boxbase: U32, +pos: U32, +mask: U32, +count: U32, +p: U32, +m: U32, +size: U32, b: Array<U32>) -> RowScan:
  match urgent:
    case True{}:
      RowDone{b, pos, mask, count}
    case False{}:
      +better = (count < size : U32)
      RowLive{b, row, bits, used, boxbase, Bool.pick(U32, better, pos, p), Bool.pick(U32, better, mask, m), Bool.pick(U32, better, count, size)}

def row_scan_take(row: U32, bits: U32, used: U32, boxbase: U32, pos: U32, p: U32, m: U32, size: U32, r: Array<U32> & U32) -> RowScan:
  (b, +mask) = r
  +count = mask_count(mask)
  row_scan_result((count <= 1 : U32), row, bits, used, boxbase, pos, mask, count, p, m, size, b)

def row_scan_step(+row: U32, bits: U32, +used: U32, +boxbase: U32, p: U32, m: U32, size: U32, b: Array<U32>) -> RowScan:
  match bits:
    case 0:
      row_scan_start((row + 1 : U32), p, m, size, Array.get(U32, b, (82 + row : U32)))
    case +present:
      +bit = U32.and(present, (0 - present : U32))
      +col = mask_count((bit - 1 : U32))
      row_scan_take(row, U32.xor(present, bit), used, boxbase, (row * 9 + col : U32), p, m, size, row_mask(b, col, boxbase, used))

def row_scan(n: Nat, state: RowScan) -> Array<U32> & Choice:
  match n state:
    case _ RowDone{b, p, m, size}:
      (b, Choice{p, m, size})
    case 0n RowLive{b, row, bits, used, boxbase, p, m, size}:
      (b, Choice{p, m, size})
    case 1n+k RowLive{b, row, bits, used, boxbase, p, m, size}:
      row_scan(k, row_scan_step(row, bits, used, boxbase, p, m, size, b))

def row_scan_begin(r: Array<U32> & U32) -> Array<U32> & Choice:
  (b, start) = r
  +row = M.div9(start)
  row_scan(U32.to_nat((90 - row : U32)), row_scan_start(row, 81, 0, 10, Array.get(U32, b, (81 + row : U32))))

def cached_select(b: Array<U32>) -> Array<U32> & Choice:
  row_scan_begin(Array.get(U32, b, 108))

# The first empty cell is a lower bound for every MRV scan. Reuse that prefix
# instead of repeatedly reading already filled cells after forced placements.
def first_empty(n: Nat, +pos: U32, r: Array<U32> & U32) -> Array<U32>:
  match n:
    case 0n:
      Array.set(U32, Pair.fst(Array<U32>, U32, r), 108, 81)
    case 1n+k:
      (b, d) = r
      match d:
        case 0:
          Array.set(U32, b, 108, pos)
        case _:
          first_empty(k, (pos + 1 : U32), Array.get(U32, b, (pos + 1 : U32)))

def refresh_start(b: Array<U32>, +pos: U32) -> Array<U32>:
  first_empty(U32.to_nat((81 - pos : U32)), pos, Array.get(U32, b, pos))

def refresh_if(needed: Bool, b: Array<U32>, start: U32) -> Array<U32>:
  match needed:
    case True{}:
      refresh_start(b, start)
    case False{}:
      b

def start_after_set(blank: Bool, +pos: U32, r: Array<U32> & U32) -> Array<U32>:
  match blank:
    case True{}:
      (b, start) = r
      Array.set(U32, b, 108, U32.min(start, pos))
    case False{}:
      (b, +start) = r
      refresh_if(U32.is_eq(pos, start), b, start)


def cache_unit_done(pos: U32, r: Array<U32> & U32) -> Array<U32>:
  (b, used) = r
  Array.set(U32, b, pos, used)

def row_used(n: Nat, +pos: U32, +col: U32, +used: U32, r: Array<U32> & U32) -> Array<U32> & U32:
  match n:
    case 0n:
      (Pair.fst(Array<U32>, U32, r), used)
    case 1n+k:
      (b, +digit) = r
      +empty = Bool.pick(U32, U32.is_eq(digit, 0), B.bit((10 + col : U32)), 0)
      row_used(k, (pos + 1 : U32), (col + 1 : U32), U32.or(used, U32.or(U32.and(B.bit(digit), 1023), empty)), Array.get(U32, b, (pos + 1 : U32)))

def cached_used(row: Bool, +unit: U32, b: Array<U32>) -> Array<U32> & U32:
  match row:
    case True{}:
      row_used(9n, (unit * 9 : U32), 0, 0, Array.get(U32, b, (unit * 9 : U32)))
    case False{}:
      unit_used(b, unit)

# Prepared parsing starts with all columns empty; each existing row update
# clears its given's bit, so blanks incur no extra per-character array write.
def empty_rows_go(n: Nat, +row: U32, b: Array<U32>) -> Array<U32>:
  match n:
    case 0n:
      b
    case 1n+k:
      empty_rows_go(k, (row + 1 : U32), Array.set(U32, b, (81 + row : U32), 523264))

def empty_rows(b: Array<U32>) -> Array<U32>:
  empty_rows_go(9n, 0, b)

def cache_units(n: Nat, +unit: U32, b: Array<U32>) -> Array<U32>:
  match n:
    case 0n:
      b
    case 1n+k:
      cache_units(k, (unit + 1 : U32), cache_unit_done((81 + unit : U32), cached_used((unit < 9 : U32), unit, b)))

def cache(b: Array<U32>) -> Array<U32>:
  refresh_start(cache_units(27n, 0, b), 0)

# Clearing the old digit then adding the replacement keeps row/column/box
# occupancy coherent on both placement and backtracking. Blank bit0 is ignored.
def update_done(pos: U32, old: U32, value: U32, r: Array<U32> & U32) -> Array<U32>:
  (b, used) = r
  Array.set(U32, b, pos, U32.or(U32.and(used, U32.not(B.bit(old))), B.bit(value)))

def update_unit(+pos: U32, old: U32, value: U32, b: Array<U32>) -> Array<U32>:
  update_done(pos, old, value, Array.get(U32, b, pos))

def row_updated(+slot: U32, old: U32, +value: U32, +empty: U32, r: Array<U32> & U32) -> Array<U32>:
  (b, used) = r
  +next = U32.or(U32.and(used, U32.not(U32.and(B.bit(old), 1023))), U32.and(B.bit(value), 1023))
  Array.set(U32, b, slot, Bool.pick(U32, U32.is_eq(value, 0), U32.or(next, empty), U32.and(next, U32.not(empty))))

def update_row(+pos: U32, old: U32, value: U32, b: Array<U32>) -> Array<U32>:
  +slot = (81 + M.div9(pos) : U32)
  row_updated(slot, old, value, B.bit((10 + M.rem9(pos) : U32)), Array.get(U32, b, slot))

def swapped(+pos: U32, +value: U32, r: Array<U32> & U32) -> Array<U32> & U32:
  (b, +old) = r
  changed = update_unit((99 + B.box_of(pos) : U32), old, value, update_unit((90 + M.rem9(pos) : U32), old, value, update_row(pos, old, value, b)))
  (start_after_set(U32.is_eq(value, 0), pos, Array.get(U32, changed, 108)), old)

def swap(b: Array<U32>, +pos: U32, +value: U32) -> Array<U32> & U32:
  swapped(pos, value, Array.swap(U32, b, pos, value))
