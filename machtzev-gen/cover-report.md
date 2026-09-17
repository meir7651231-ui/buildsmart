# כיסוי-שקעים (cover · G3) — שחזור טבלת-ATOM הידנית

**top-1: 20/58** (תצוגה 13/28 · לוגיקה 7/30) · **top-3: 29/58** (תצוגה 19/28 · לוגיקה 10/30)

| op | ביד | המנוע (top-1) | top-3 | ✓ |
|---|---|---|---|---|
| magnitude→stat | BareStat | KpiTile | KpiTile · ProgressRing · StatHero | ✗ |
| headline→stat | KpiTile | KpiTile | KpiTile · ProgressRing · StatHero | ✓ |
| hero→stat | stat_hero | StatHero | StatHero · KpiTile · ProgressRing | ✗ |
| ratio→ratio | StatRow | StatRow | StatRow · CreditBar · ProgressStatRow | ✓ |
| compare→bars | NeonBars | DsBars | DsBars · NeonBars · DonutChart | ≈ |
| diff→stat | BareStat | KpiTile | KpiTile · ProgressRing · StatHero | ✗ |
| fact→fact | StatusChip | DsChip | DsChip · DsEmpty · StatusChip | ≈ |
| group→group | DsSection | DsSection | DsSection · SectionHeader · AnimatedEmpty | ✓ |
| identity→identity | MediaRow | GlassListTile | GlassListTile · HeroHeader · MediaRow | ≈ |
| action→action | SoftButton | DsPrimaryButton | DsPrimaryButton · GlassButton · GradButton | ✗ |
| search→field | DsSearch | DsSearch | DsSearch · DsMultiSelect · DsDateField | ✓ |
| match→transform | smartFilter | smartScore | smartScore · studentHistoryText · ruleExact | ✗ |
| filter→filter | FilterChipPill | FilterChipPill | FilterChipPill · PresetChip · SeverityChip | ✓ |
| predicate→predicate | finderMatches | matchSegment | matchSegment · makeupEligibility · canIssueReceipt | ✗ |
| serialize→transform | toCsv | csvEscape | csvEscape · visibleEventsForDesignations · receiptFmtOf | ✗ |
| switch→switch | SegmentedSwitch | SegmentedSwitch | SegmentedSwitch · SegmentedPillToggle | ✓ |
| role→format | roleOf | canGrantedAction | canGrantedAction · donCalMonthLine · docSkey | ✗ |
| grant→predicate | canGrantedAction | canGrantedAction | canGrantedAction · isMember · isAdminUser | ✓ |
| alert→alert | AlertBanner | ToastCard | ToastCard · AlertBanner | ≈ |
| expiry→collection | expiringIntakes | isContiguousSubsequence | isContiguousSubsequence · nextClosure · punchConfirmStep | ✗ |
| capital→measure | warehouseValue | assistantIntentPrompt | assistantIntentPrompt · connectionFailReason · criticalOpen | ✗ |
| table→table | DsTable | DsTable | DsTable | ✓ |
| panel→panel | GlassCard | DsCardElevated | DsCardElevated · DsCardGlass · DsCardGradient | ✗ |
| timeline→timeline | TimelineItem | TimelineItem | TimelineItem | ✓ |
| empty→empty | EmptyState | EmptyStateCard | EmptyStateCard · SearchEmptyState · EmptyState | ≈ |
| trend→trend | TrendStat | TrendStat | TrendStat · PremiumStat | ✓ |
| ring→stat | ProgressRing | KpiTile | KpiTile · ProgressRing · StatHero | ≈ |
| gauge→stat | GaugeMeter | KpiTile | KpiTile · ProgressRing · StatHero | ✗ |
| bars→bars | DsBars | DonutChart | DonutChart · LineSpark · NeonBars | ✗ |
| avatar→identity | AvatarTile | AvatarTile | AvatarTile · GlassListTile · HeroHeader | ✓ |
| expand→expand | ExpandableTile | ExpandableTile | ExpandableTile · FeaturePanel · RegressionBody | ✓ |
| field→field | DsField | DsSearch | DsSearch · SearchField · DsDateField | ✗ |
| enumfield→field | DsEnumField | DsSearch | DsSearch · SearchField · DsDateField | ✗ |
| board→board | DsBoard | DsBoard | DsBoard | ✓ |
| primary→action | DsPrimaryButton | DsPrimaryButton | DsPrimaryButton · GlassButton · GradButton | ✓ |
| queue→collection | cockpitQueue | cockpitHokTasks | cockpitHokTasks · blockReason · donorConstellation | ✗ |
| progress→summary | cockpitProgress | blockReason | blockReason · donCalMonthLine · makeupEligibility | ✗ |
| sheet→transform | sheetSummary | sheetSummary | sheetSummary · presentsInMonth · sheetRoster | ✓ |
| makeup→collection | pendingMakeups | makeupEligibility | makeupEligibility · pendingMakeups · completion | ≈ |
| balance→measure | payBal | payBal | payBal · balanceOf · payCredit | ✓ |
| paidstatus→format | enrollmentPaidStatus | studioScopePrompt | studioScopePrompt · baseColor · payBal | ✗ |
| hok→collection | hokDue | cockpitHokTasks | cockpitHokTasks · hokRecordedThisMonth · detectRecurringHok | ✗ |
| clash→format | scheduleClashText | minToHM | minToHM · roomInfoLabel · courseDateError | ✗ |
| slots→collection | buildSlots | buildSlots | buildSlots · inactiveRoomCourses · groupOptionsOf | ✓ |
| block→format | blockReason | holidayOf | holidayOf · blockReason · auditLine | ≈ |
| holiday→format | holidayOf | holidayOf | holidayOf · blockReason · roomInfoLabel | ✓ |
| weekly→collection | weeklyRoomSessions | roomInfoLabel | roomInfoLabel · weeklyRoomSessions · buildSlots | ≈ |
| sessions→collection | sessionsOf | roomInfoLabel | roomInfoLabel · buildSlots · inactiveRoomCourses | ✗ |
| enrol→measure | enrollCount | enrollCount | enrollCount · lessonPriceForTier · courseDateError | ✓ |
| wait→collection | waitlistFor | roomsNow | roomsNow · deliveriesOfDay · suggestions | ✗ |
| byteacher→collection | coursesOfTeacher | deliveriesOfDay | deliveriesOfDay · suggestions · filterAyinBoard | ✗ |
| whoami→format | teacherIdOf | donCalMonthLine | donCalMonthLine · scheduleTasks · studioScopePrompt | ✗ |
| cert→format | certExpiryStatus | ayinAdvanceLabel | ayinAdvanceLabel · assistantIntentPrompt · docSkey | ✗ |
| contact→format | waLink | formatIsraeliPhone | formatIsraeliPhone · studentHistoryText · fixPhone | ✗ |
| recipients→collection | bulkWaRecipients | famLiveEnrollments | famLiveEnrollments · findDuplicateGroups · deliveriesOfDay | ✗ |
| template→format | renderTemplate | assistantIntentPrompt | assistantIntentPrompt · connectionFailReason · studioScopePrompt | ✗ |
| parse→collection | parseCsv | previewTelephony | previewTelephony · advanceStatus · importableContacts | ✗ |
| trendengine→summary | trendFromScan | trendFromScan | trendFromScan · studentHistoryText · churnFromScan | ✓ |
