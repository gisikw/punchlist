building file list ... done
Punchlist/ViewModels/
Punchlist/ViewModels/PunchlistViewModel.swift
Punchlist/Views/
Punchlist/Views/ContentView.swift
Punchlist/Views/ItemRow.swift

sent 1,548 bytes  received 430 bytes  1,318.67 bytes/sec
total size is 477,255  speedup is 241.28

2026-02-26 14:25:41.860 xcodebuild[93194:3716275] [MT] IDETestOperationsObserverDebug: 21.724 elapsed -- Testing started completed.
2026-02-26 14:25:41.860 xcodebuild[93194:3716275] [MT] IDETestOperationsObserverDebug: 0.000 sec, +0.000 sec -- start
2026-02-26 14:25:41.860 xcodebuild[93194:3716275] [MT] IDETestOperationsObserverDebug: 21.724 sec, +21.724 sec -- end

Test session results, code coverage, and logs:
	/Users/admin/Library/Developer/Xcode/DerivedData/Punchlist-blurehbcsnlqphfanvzkacxlfvuh/Logs/Test/Test-PunchlistTests-2026.02.26_14-25-18--0600.xcresult

** TEST SUCCEEDED **

Testing started
Test suite 'PlanQuestionDecodingTests' started on 'Clone 1 of iPhone 17 Pro - Punchlist (93459)'
Test case 'PlanQuestionDecodingTests.testDecodePlanQuestion()' passed on 'Clone 1 of iPhone 17 Pro - Punchlist (93459)' (0.002 seconds)
Test case 'PlanQuestionDecodingTests.testDecodePlanQuestionWithoutContext()' passed on 'Clone 1 of iPhone 17 Pro - Punchlist (93459)' (0.000 seconds)
Test case 'PlanQuestionDecodingTests.testPlanOptionId()' passed on 'Clone 1 of iPhone 17 Pro - Punchlist (93459)' (0.000 seconds)
Test suite 'ItemDecodingTests' started on 'Clone 1 of iPhone 17 Pro - Punchlist (93459)'
Test case 'ItemDecodingTests.testDecodeItemMinimalRequired()' passed on 'Clone 1 of iPhone 17 Pro - Punchlist (93459)' (0.001 seconds)
Test case 'ItemDecodingTests.testDecodeItemTitleMapping()' passed on 'Clone 1 of iPhone 17 Pro - Punchlist (93459)' (0.000 seconds)
Test case 'ItemDecodingTests.testDecodeItemWithAllFields()' passed on 'Clone 1 of iPhone 17 Pro - Punchlist (93459)' (0.000 seconds)
Test case 'ItemDecodingTests.testDecodeItemWithOpenStatus()' passed on 'Clone 1 of iPhone 17 Pro - Punchlist (93459)' (0.000 seconds)
Test case 'ItemDecodingTests.testDecodeItemWithStatus()' passed on 'Clone 1 of iPhone 17 Pro - Punchlist (93459)' (0.002 seconds)
Test suite 'PollingFallbackTests' started on 'Clone 1 of iPhone 17 Pro - Punchlist (93459)'
Test case 'PollingFallbackTests.testBurstPollingAfterMutations()' passed on 'Clone 1 of iPhone 17 Pro - Punchlist (93459)' (0.000 seconds)
Test case 'PollingFallbackTests.testConnectionObserverDetectsDisconnect()' passed on 'Clone 1 of iPhone 17 Pro - Punchlist (93459)' (0.000 seconds)
Test case 'PollingFallbackTests.testOfflineMutationsAreOptimistic()' passed on 'Clone 1 of iPhone 17 Pro - Punchlist (93459)' (0.000 seconds)
Test case 'PollingFallbackTests.testOfflineQueueDrains()' passed on 'Clone 1 of iPhone 17 Pro - Punchlist (93459)' (0.000 seconds)
Test case 'PollingFallbackTests.testPollingBreaksOnSSEReconnect()' passed on 'Clone 1 of iPhone 17 Pro - Punchlist (93459)' (0.013 seconds)
Test case 'PollingFallbackTests.testPollingDoesNotStartWhenAlreadyRunning()' passed on 'Clone 1 of iPhone 17 Pro - Punchlist (93459)' (0.000 seconds)
Test case 'PollingFallbackTests.testPollingFetchesCurrentProject()' passed on 'Clone 1 of iPhone 17 Pro - Punchlist (93459)' (0.000 seconds)
Test case 'PollingFallbackTests.testPollingStartsWhenSSEDisconnects()' passed on 'Clone 1 of iPhone 17 Pro - Punchlist (93459)' (0.000 seconds)
Test case 'PollingFallbackTests.testPollingStopsOnTaskCancellation()' passed on 'Clone 1 of iPhone 17 Pro - Punchlist (93459)' (0.000 seconds)
Test case 'PollingFallbackTests.testPollingStopsWhenSSEReconnects()' passed on 'Clone 1 of iPhone 17 Pro - Punchlist (93459)' (0.004 seconds)
Test case 'PollingFallbackTests.testPollingUpdatesFilteredItems()' passed on 'Clone 1 of iPhone 17 Pro - Punchlist (93459)' (0.000 seconds)
Test case 'PollingFallbackTests.testShowOfflineUILogic()' passed on 'Clone 1 of iPhone 17 Pro - Punchlist (93459)' (0.000 seconds)
Test case 'PollingFallbackTests.testSteadyStatePollingInterval()' passed on 'Clone 1 of iPhone 17 Pro - Punchlist (93459)' (0.000 seconds)
Test suite 'FilteringTests' started on 'Clone 1 of iPhone 17 Pro - Punchlist (93459)'
Test case 'FilteringTests.testFilteringLogicEdgeCase()' passed on 'Clone 1 of iPhone 17 Pro - Punchlist (93459)' (0.001 seconds)
Test case 'FilteringTests.testPersonalProjectShowsAllItems()' passed on 'Clone 1 of iPhone 17 Pro - Punchlist (93459)' (0.000 seconds)
Test case 'FilteringTests.testProjectViewDisabledShowCompletedFromSession()' passed on 'Clone 1 of iPhone 17 Pro - Punchlist (93459)' (0.001 seconds)
Test case 'FilteringTests.testProjectViewExcludesClosedModifiedBeforeSession()' passed on 'Clone 1 of iPhone 17 Pro - Punchlist (93459)' (0.001 seconds)
Test case 'FilteringTests.testProjectViewExcludesClosedWithoutModifiedTimestamp()' passed on 'Clone 1 of iPhone 17 Pro - Punchlist (93459)' (0.000 seconds)
Test case 'FilteringTests.testProjectViewHidesClosedItems()' passed on 'Clone 1 of iPhone 17 Pro - Punchlist (93459)' (0.000 seconds)
Test case 'FilteringTests.testProjectViewIncludesClosedFromSessionWhenEnabled()' passed on 'Clone 1 of iPhone 17 Pro - Punchlist (93459)' (0.001 seconds)
Test case 'FilteringTests.testProjectViewNilSessionStart()' passed on 'Clone 1 of iPhone 17 Pro - Punchlist (93459)' (0.000 seconds)
Test suite 'ProjectDecodingTests' started on 'Clone 1 of iPhone 17 Pro - Punchlist (93459)'
Test case 'ProjectDecodingTests.testDecodeProjectDefaultFalse()' passed on 'Clone 1 of iPhone 17 Pro - Punchlist (93459)' (0.001 seconds)
Test case 'ProjectDecodingTests.testDecodeProjectMinimal()' passed on 'Clone 1 of iPhone 17 Pro - Punchlist (93459)' (0.000 seconds)
Test case 'ProjectDecodingTests.testDecodeProjectWithDefault()' passed on 'Clone 1 of iPhone 17 Pro - Punchlist (93459)' (0.000 seconds)
Test case 'ProjectDecodingTests.testProjectId()' passed on 'Clone 1 of iPhone 17 Pro - Punchlist (93459)' (0.000 seconds)
Test case 'ProjectDecodingTests.testProjectTagMapping()' passed on 'Clone 1 of iPhone 17 Pro - Punchlist (93459)' (0.000 seconds)
