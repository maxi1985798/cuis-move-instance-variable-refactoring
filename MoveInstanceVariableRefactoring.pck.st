'From Cuis 6.0 [latest update: #5981] on 15 January 2024 at 1:11:10 am'!
'Description '!
!provides: 'MoveInstanceVariableRefactoring' 1 43!
SystemOrganization addCategory: 'MoveInstanceVariableRefactoring'!


!classDefinition: #CodeForNodeOnMethod category: 'MoveInstanceVariableRefactoring'!
ParseNodeVisitor subclass: #CodeForNodeOnMethod
	instanceVariableNames: 'node instanceVariableName compiledMethod intervalsToModify methodNode instVarNameTargetClass nodeInterval newCodeForNode nodeOffsetInSourceCode intervalsToReject modifiedReads modifiedWrites getterToUse setterToUse'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'MoveInstanceVariableRefactoring'!
!classDefinition: 'CodeForNodeOnMethod class' category: 'MoveInstanceVariableRefactoring'!
CodeForNodeOnMethod class
	instanceVariableNames: ''!

!classDefinition: #MoveInstanceVariableTest category: 'MoveInstanceVariableRefactoring'!
RefactoringTest subclass: #MoveInstanceVariableTest
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'MoveInstanceVariableRefactoring'!
!classDefinition: 'MoveInstanceVariableTest class' category: 'MoveInstanceVariableRefactoring'!
MoveInstanceVariableTest class
	instanceVariableNames: ''!

!classDefinition: #MoveInstanceVariableRefactoring category: 'MoveInstanceVariableRefactoring'!
Refactoring subclass: #MoveInstanceVariableRefactoring
	instanceVariableNames: 'instVarNameSourceClass sourceClass targetClass instVarNameTargetClass modifiedReads modifiedWrites getterToUse setterToUse'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'MoveInstanceVariableRefactoring'!
!classDefinition: 'MoveInstanceVariableRefactoring class' category: 'MoveInstanceVariableRefactoring'!
MoveInstanceVariableRefactoring class
	instanceVariableNames: ''!

!classDefinition: #MoveInstanceVariableApplier category: 'MoveInstanceVariableRefactoring'!
TransferInstanceVariableApplier subclass: #MoveInstanceVariableApplier
	instanceVariableNames: 'accessingThroughinstanceVariableName targetClass'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'MoveInstanceVariableRefactoring'!
!classDefinition: 'MoveInstanceVariableApplier class' category: 'MoveInstanceVariableRefactoring'!
MoveInstanceVariableApplier class
	instanceVariableNames: ''!

!classDefinition: #MoveInstanceVariableWithActualScopeApplier category: 'MoveInstanceVariableRefactoring'!
MoveInstanceVariableApplier subclass: #MoveInstanceVariableWithActualScopeApplier
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'MoveInstanceVariableRefactoring'!
!classDefinition: 'MoveInstanceVariableWithActualScopeApplier class' category: 'MoveInstanceVariableRefactoring'!
MoveInstanceVariableWithActualScopeApplier class
	instanceVariableNames: ''!

!classDefinition: #CodeForNodeResult category: 'MoveInstanceVariableRefactoring'!
Object subclass: #CodeForNodeResult
	instanceVariableNames: 'modifiedReads modifiedWrites resultCode'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'MoveInstanceVariableRefactoring'!
!classDefinition: 'CodeForNodeResult class' category: 'MoveInstanceVariableRefactoring'!
CodeForNodeResult class
	instanceVariableNames: ''!

!classDefinition: #TesisRefactoringMenu category: 'MoveInstanceVariableRefactoring'!
Object subclass: #TesisRefactoringMenu
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'MoveInstanceVariableRefactoring'!
!classDefinition: 'TesisRefactoringMenu class' category: 'MoveInstanceVariableRefactoring'!
TesisRefactoringMenu class
	instanceVariableNames: ''!


!CodeForNodeOnMethod commentStamp: '<historical>' prior: 0!
this class returns the code that belongs to "node" with "instanceVariableName" moved!

!TesisRefactoringMenu commentStamp: '<historical>' prior: 0!
Please remove this class after integration!

!CodeForNodeOnMethod methodsFor: 'initialization' stamp: 'mc 11/7/2023 22:48:24'!
initializeFor: aNode replace: instVarNameToReplace onMethod: aCompiledMethod accessingThrough: instVarNameToUseAsReceiver usingGetter: aGetterToUse usingSetter: aSetterToUse rejectingIntervals: intervals 
	node := aNode.
	instanceVariableName := instVarNameToReplace.
	compiledMethod := aCompiledMethod.
	instVarNameTargetClass := instVarNameToUseAsReceiver.
	methodNode := compiledMethod notOptimizedMethodNode.
	intervalsToModify := OrderedCollection new.
	intervalsToReject := intervals.
	modifiedReads := 0.
	modifiedWrites := 0.
	getterToUse := aGetterToUse .
	setterToUse := aSetterToUse ! !

!CodeForNodeOnMethod methodsFor: 'visiting' stamp: 'mc 11/7/2023 22:50:30'!
visitAssignmentNode: anAssignmentNode 
	| rangesOfassigmentNode assigmentValue newAssignmentCode newCodeForValue nodeReplacer resultForValue |

	anAssignmentNode variable name = instanceVariableName ifFalse: [anAssignmentNode value accept: self. ^self].
	
	rangesOfassigmentNode := self firstUnseenIntervalFor: anAssignmentNode.
	nodeReplacer := CodeForNodeOnMethod 
					replace: instanceVariableName 
					onMethod: compiledMethod 
					accessingThrough: instVarNameTargetClass 
					usingGetter: getterToUse
					usingSetter: setterToUse
					for: anAssignmentNode value 
					rejectingIntervals: intervalsToReject.
	resultForValue :=			nodeReplacer value.
	newCodeForValue := resultForValue resultCode .
	(((anAssignmentNode value isMessageNode and: [anAssignmentNode value isKeywordMessageSend])) or: [anAssignmentNode value isAssignmentNode ])
		ifTrue: [assigmentValue := '(', newCodeForValue, ')'.] 
		ifFalse: [assigmentValue := newCodeForValue.].
	newAssignmentCode := instVarNameTargetClass, ' ', setterToUse, ' ', assigmentValue.
	self registerInterval: rangesOfassigmentNode withModification: newAssignmentCode.
	modifiedWrites := modifiedWrites + 1.
	modifiedReads := modifiedReads + resultForValue modifiedReads.! !

!CodeForNodeOnMethod methodsFor: 'visiting' stamp: 'mc 11/7/2023 00:46:27'!
visitInstanceVariableNode: anInstanceVariableNode 
	| newReadWithGetterCode intervalForInstanceVariableNode |
	
	anInstanceVariableNode name = instanceVariableName ifFalse: [^self].
	intervalForInstanceVariableNode := self firstUnseenIntervalFor: anInstanceVariableNode.
	newReadWithGetterCode := instVarNameTargetClass, ' ', getterToUse .
	self registerInterval: intervalForInstanceVariableNode withModification: newReadWithGetterCode.
	modifiedReads := modifiedReads + 1. ! !

!CodeForNodeOnMethod methodsFor: 'accessing' stamp: 'mc 3/7/2023 01:34:38'!
modifiedReads
	^modifiedReads 
! !

!CodeForNodeOnMethod methodsFor: 'accessing' stamp: 'mc 3/7/2023 01:34:56'!
modifiedWrites
	^modifiedWrites ! !

!CodeForNodeOnMethod methodsFor: 'accessing' stamp: 'HAW 3/14/2023 12:25:42'!
value
	
	self initializeNodeInterval.
	self initializeOffset.
	self intervalsToModify.
	^self newModifiedCode.
	
! !

!CodeForNodeOnMethod methodsFor: 'private' stamp: 'mc 2/22/2023 01:46:32'!
filterRangesThatDoNotBelongToTheCurrentNodeIn: aCollectionOfRanges

	^ self firstIntervalOn: (aCollectionOfRanges select: [ :anInterval | nodeInterval includesAllOf: anInterval ])! !

!CodeForNodeOnMethod methodsFor: 'private' stamp: 'mc 2/22/2023 00:38:31'!
firstIntervalOn: aCollectionOfIntervals
	^aCollectionOfIntervals detectMin: [ :anInterval | anInterval first]! !

!CodeForNodeOnMethod methodsFor: 'private' stamp: 'mc 2/25/2023 19:34:35'!
firstUnseenIntervalFor: aNode

	| completeRangesOfassigmentNode |
	
	completeRangesOfassigmentNode := self sourceRangesOf: aNode.
	self removeSeenRanges: completeRangesOfassigmentNode.
	^self filterRangesThatDoNotBelongToTheCurrentNodeIn: completeRangesOfassigmentNode.! !

!CodeForNodeOnMethod methodsFor: 'private' stamp: 'mc 2/22/2023 01:47:45'!
initializeNodeInterval

	| posibleRangesForNode |
	node isMethodNode 
		ifTrue:[ nodeInterval := 1 to: (compiledMethod sourceCode size) ]
		ifFalse:[ 
			posibleRangesForNode _ self sourceRangesOf: node.
			self removeSeenRanges: posibleRangesForNode.
			nodeInterval _ self firstIntervalOn: posibleRangesForNode.
			]! !

!CodeForNodeOnMethod methodsFor: 'private' stamp: 'mc 2/22/2023 02:18:37'!
initializeOffset

	^ nodeOffsetInSourceCode := nodeInterval first -1! !

!CodeForNodeOnMethod methodsFor: 'private' stamp: 'HAW 3/14/2023 12:25:23'!
intervalsToModify

	node accept: self.
	intervalsToModify := intervalsToModify collect: [ :anAssociation | (anAssociation key - nodeOffsetInSourceCode) -> anAssociation value ]! !

!CodeForNodeOnMethod methodsFor: 'private' stamp: 'HAW 3/14/2023 12:25:42'!
newModifiedCode

	| newCode |
	newCodeForNode := compiledMethod sourceCode copyFrom: nodeInterval first to: nodeInterval last.
	newCode := newCodeForNode copyReplacing: intervalsToModify.
	^CodeForNodeResult newWith: newCode modifiedReads: modifiedReads modifiedWrites: modifiedWrites.! !

!CodeForNodeOnMethod methodsFor: 'private' stamp: 'mc 2/25/2023 16:17:24'!
registerInterval: anIntervalToModify withModification: sourceCodeForInterval

	intervalsToReject add: anIntervalToModify.
	intervalsToModify add: anIntervalToModify -> sourceCodeForInterval! !

!CodeForNodeOnMethod methodsFor: 'private' stamp: 'mc 2/21/2023 23:35:33'!
removeSeenRanges: rangesOfNode

	^ rangesOfNode removeAllSuchThat: [ :aSourceInterval | intervalsToReject anySatisfy: [ :aSourceIntervalToModify | aSourceIntervalToModify includesAllOf: aSourceInterval ] ]! !

!CodeForNodeOnMethod methodsFor: 'private' stamp: 'mc 2/20/2023 18:45:10'!
sourceRangesOf: aNode
	
	^methodNode completeSourceRangesOf: aNode ifAbsent: []! !

!CodeForNodeOnMethod class methodsFor: 'instance creation' stamp: 'mc 11/7/2023 22:46:52'!
replace: instVarNameToReplace onMethod: aCompiledMethod accessingThrough: instVarNameToUseAsReceiver 
	^self 
		replace: instVarNameToReplace 
		onMethod: aCompiledMethod 
		accessingThrough: instVarNameToUseAsReceiver
		usingGetter: instVarNameToReplace asSymbol
		usingSetter: (instVarNameToReplace, ':') asSymbol 
		for: aCompiledMethod notOptimizedMethodNode! !

!CodeForNodeOnMethod class methodsFor: 'instance creation' stamp: 'mc 11/7/2023 23:14:39'!
replace: anInstVarNameSourceClass onMethod: aMethod accessingThrough: anInstVarNameTargetClass usingGetter: aGetterToUse 
	^self 
		replace: anInstVarNameSourceClass
		onMethod: aMethod
		accessingThrough: anInstVarNameTargetClass
		usingGetter: aGetterToUse
		usingSetter: (anInstVarNameSourceClass, ':') asSymbol 
		for: aMethod notOptimizedMethodNode! !

!CodeForNodeOnMethod class methodsFor: 'instance creation' stamp: 'mc 11/7/2023 22:45:52'!
replace: anInstVarNameSourceClass onMethod: aMethod accessingThrough: anInstVarNameTargetClass usingGetter: aGetterToUse usingSetter: aSetterToUse 

	^self 
		replace: anInstVarNameSourceClass
		onMethod: aMethod
		accessingThrough: anInstVarNameTargetClass
		usingGetter: aGetterToUse
		usingSetter: aSetterToUse
		for: aMethod notOptimizedMethodNode! !

!CodeForNodeOnMethod class methodsFor: 'instance creation' stamp: 'mc 11/7/2023 22:46:02'!
replace: instVarNameToReplace onMethod: aCompiledMethod accessingThrough: instVarNameToUseAsReceiver usingGetter: aGetterToUse usingSetter: aSetterToUse  for: aNode
	^self 
		replace: instVarNameToReplace 
		onMethod: aCompiledMethod 
		accessingThrough: instVarNameToUseAsReceiver 
		usingGetter: aGetterToUse
		usingSetter: aSetterToUse
		for: aNode
		rejectingIntervals: OrderedCollection new! !

!CodeForNodeOnMethod class methodsFor: 'instance creation' stamp: 'mc 11/7/2023 22:46:08'!
replace: instVarNameToReplace onMethod: aCompiledMethod accessingThrough: instVarNameToUseAsReceiver usingGetter: aGetterToUse usingSetter: aSetterToUse  for: aNode rejectingIntervals: intervals
	^self new 
		initializeFor: aNode 
		replace: instVarNameToReplace 
		onMethod: aCompiledMethod 
		accessingThrough: instVarNameToUseAsReceiver 
		usingGetter: aGetterToUse
		usingSetter: aSetterToUse
		rejectingIntervals: intervals! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 10/21/2022 17:51:06'!
codeWithBadIdentation

^ 
'iv6:
anObject
iv6 
:=
anObject.'! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 11/22/2022 03:08:32'!
expectedCodeWitBadIdentation

^
'iv6:
anObject
iv2 iv6: anObject.'! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 10/23/2022 23:55:51'!
setterWithTwoAssignations

^ 
'iv6: anObject
iv6 := anObject.
iv6 := anObject.'! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 10/23/2022 23:59:15'!
setterWithTwoAssignationsAfterRefactoring

^ 
'iv6: anObject
iv2 iv6: anObject.
iv2 iv6: anObject.'! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'HAW 3/14/2023 12:20:16'!
test01CanMoveInstVarWhenThereIsNoReferenceToSourceIV

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv1 iv2'.
	targetClass  := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRefactoring named: 'iv1' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self deny: (sourceClass instVarNames includes: 'iv1').
	self assert: (targetClass instVarNames includes: 'iv1').
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 3/24/2023 00:48:13'!
test02CanMoveInstVarWhenThereIsAReferenceToSourceIV

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv1 iv2'.
	sourceClass compile: 'iv1 ^iv1' .
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRefactoring named: 'iv1' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self assert: 'iv1', String newLineString, String tab, '^iv1' equals: (targetClass compiledMethodAt: #iv1) sourceCode.
	self assert: 'iv1 ^iv2 iv1' equals: (sourceClass compiledMethodAt: #iv1) sourceCode.
	self assert: 1 equals: targetClass methodCategories size.
	self assert: MoveInstanceVariableRefactoring getterSetterCategoryName equals: targetClass methodCategories first.
	self assert: 1 equals: (targetClass selectorsInCategory: MoveInstanceVariableRefactoring getterSetterCategoryName) size.
	self assert: #iv1 equals: (targetClass selectorsInCategory: MoveInstanceVariableRefactoring getterSetterCategoryName) first.
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 11/6/2023 23:53:52'!
test02CanMoveInstVarWhenThereIsAReferenceToSourceIVAndUseADifferentGetterAsSelector

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv1 iv2'.
	targetClass := self createClassNamed: #TargetClass.
	sourceClass compile: 'iv1 ^iv1' .
	
	refactoring := MoveInstanceVariableRefactoring 
					named: 'iv1' 
					from: sourceClass 
					to: targetClass 
					accessingThrough: 'iv2' 
					usingGetter: #iv1Getter.
	refactoring apply.
	
	self assert: 'iv1Getter', String newLineString, String tab, '^iv1' equals: (targetClass sourceCodeAt: #iv1Getter).
	self assert: 'iv1 ^iv2 iv1Getter' equals: (sourceClass compiledMethodAt: #iv1) sourceCode.
	self assert: 1 equals: targetClass methodCategories size.
	self assert: MoveInstanceVariableRefactoring getterSetterCategoryName equals: targetClass methodCategories first.
	self assert: 1 equals: (targetClass selectorsInCategory: MoveInstanceVariableRefactoring getterSetterCategoryName) size.
	self assert: #iv1Getter equals: (targetClass selectorsInCategory: MoveInstanceVariableRefactoring getterSetterCategoryName) first.
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'HAW 3/14/2023 12:20:16'!
test03CanMoveInstVarWhenThereIsAReferenceToSourceIV

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv5'.
	sourceClass compile: 'iv5 ^iv5'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRefactoring named: 'iv5' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self assert: 'iv5', String newLineString, String tab, '^iv5' equals: (targetClass compiledMethodAt: #iv5) sourceCode.
	self assert: 'iv5 ^iv2 iv5' equals: (sourceClass compiledMethodAt: #iv5) sourceCode.
	
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'HAW 3/14/2023 12:20:16'!
test04MoveInstVarWithNoReferencesShouldNotCreateGetterOnTarget

	| refactoring sourceClass targetClass targetMessages |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv1 iv2'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRefactoring named: 'iv1' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	targetMessages := targetClass methodDictionary keys .
	self deny: (targetMessages includes: #iv1).
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'HAW 3/14/2023 12:20:16'!
test05CanMoveInstVarWhenThereIsAReferenceToSourceIV

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv3 iv5'.
	sourceClass compile: 'iv5 ^iv5'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRefactoring named: 'iv5' from: sourceClass to: targetClass accessingThrough: 'iv3'.
	refactoring apply.
	
	self assert: 'iv5', String newLineString, String tab, '^iv5' equals: (targetClass compiledMethodAt: #iv5) sourceCode.
	self assert: 'iv5 ^iv3 iv5' equals: (sourceClass compiledMethodAt: #iv5) sourceCode.
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'HAW 3/14/2023 12:20:16'!
test06MoveInstVarWithNoReaderReferencesShouldNotCreateGetterOnTarget

	| refactoring sourceClass targetClass targetMessages |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv1 iv2'.
	sourceClass compile: 'iv1: anObject iv1 := anObject.'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRefactoring named: 'iv1' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	targetMessages := targetClass methodDictionary keys .
	self deny: (targetMessages includes: #iv1).
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'HAW 3/14/2023 12:20:16'!
test07CanMoveInstVarWhenThereAreTwoReferencesToSourceIV

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv5'.
	sourceClass compile: 'firstRef ^iv5'.
	sourceClass compile: 'secondRef ^iv5'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRefactoring named: 'iv5' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self assert: 'iv5', String newLineString, String tab, '^iv5' equals: (targetClass compiledMethodAt: #iv5) sourceCode.
	self assert: 'firstRef ^iv2 iv5' equals: (sourceClass compiledMethodAt: #firstRef) sourceCode.
	self assert: 'secondRef ^iv2 iv5' equals: (sourceClass compiledMethodAt: #secondRef) sourceCode.
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 3/24/2023 00:48:38'!
test08CanMoveInstVarWhenThereIsAWriteReferencesToSourceIV

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv5'.
	sourceClass compile: 'iv5: anObject iv5 := anObject.'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRefactoring named: 'iv5' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self deny: (sourceClass instVarNames includes: 'iv5').
	self assert: (targetClass instVarNames includes: 'iv5').
	self assert: 'iv5: anObject', String newLineString, String tab, '^iv5 := anObject.' equals: (targetClass compiledMethodAt: #iv5:) sourceCode.
	self assert: 'iv5: anObject iv2 iv5: anObject.' equals: (sourceClass compiledMethodAt: #iv5:) sourceCode.
	self assert: 1 equals: targetClass methodCategories size.
	self assert: MoveInstanceVariableRefactoring getterSetterCategoryName equals: targetClass methodCategories first.
	self assert: 1 equals: (targetClass selectorsInCategory: MoveInstanceVariableRefactoring getterSetterCategoryName) size.
	self assert: #iv5: equals: (targetClass selectorsInCategory: MoveInstanceVariableRefactoring getterSetterCategoryName) first.
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'HAW 3/14/2023 12:20:16'!
test09CanMoveInstVarWhenThereIsAWriteReferencesToSourceIV

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv6'.
	sourceClass compile: 'iv6: anObject iv6 := anObject.'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRefactoring named: 'iv6' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self deny: (sourceClass instVarNames includes: 'iv6').
	self assert: (targetClass instVarNames includes: 'iv6').
	self assert: 'iv6: anObject', String newLineString, String tab,'^iv6 := anObject.' equals: (targetClass compiledMethodAt: #iv6:) sourceCode.
	self assert: 'iv6: anObject iv2 iv6: anObject.' equals: (sourceClass compiledMethodAt: #iv6:) sourceCode.
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 11/7/2023 22:52:18'!
test09CanMoveInstVarWhenThereIsAWriteReferencesToSourceIVAndUseADifferentSetterName

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv6'.
	sourceClass compile: 'iv6: anObject iv6 := anObject.'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRefactoring 
					named: 'iv6' 
					from: sourceClass
					to: targetClass
					accessingThrough: 'iv2'
					usingGetter: #iv6 
					usingSetter: #iv6Setter: 
					.
	refactoring apply.
	
	self deny: (sourceClass instVarNames includes: 'iv6').
	self assert: (targetClass instVarNames includes: 'iv6').
	self assert: 'iv6Setter: anObject', String newLineString, String tab,'^iv6 := anObject.' equals: (targetClass compiledMethodAt: #iv6Setter:) sourceCode.
	self assert: 'iv6: anObject iv2 iv6Setter: anObject.' equals: (sourceClass compiledMethodAt: #iv6:) sourceCode.
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'HAW 3/14/2023 12:20:16'!
test10IdentationShouldNotBeAProblemToMoveInstVar

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv6'.
	sourceClass compile: self codeWithBadIdentation.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRefactoring named: 'iv6' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self deny: (sourceClass instVarNames includes: 'iv6').
	self assert: (targetClass instVarNames includes: 'iv6').
	self assert: 'iv6: anObject', String newLineString, String tab,'^iv6 := anObject.' equals: (targetClass compiledMethodAt: #iv6:) sourceCode.
	self assert: self expectedCodeWitBadIdentation equals: (sourceClass compiledMethodAt: #iv6:) sourceCode.
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'HAW 3/14/2023 12:20:16'!
test11CanMoveInstVarWhenThereAreTwoAssignationsOnSameMethod

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv6'.
	sourceClass compile: self setterWithTwoAssignations.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRefactoring named: 'iv6' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self deny: (sourceClass instVarNames includes: 'iv6').
	self assert: (targetClass instVarNames includes: 'iv6').
	self assert: 'iv6: anObject', String newLineString, String tab, '^iv6 := anObject.' equals: (targetClass compiledMethodAt: #iv6:) sourceCode.
	self assert: self setterWithTwoAssignationsAfterRefactoring equals: (sourceClass compiledMethodAt: #iv6:) sourceCode.! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'HAW 3/14/2023 12:20:16'!
test12CanMoveInstVarWhenThereAreTwoAssignationsOnSameMethod

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv6'.
	sourceClass compile:  
'iv6: anObject
|tmpvar|
iv6 := anObject.
tmpvar := anObject.
iv6 := tmpvar.'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRefactoring named: 'iv6' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self deny: (sourceClass instVarNames includes: 'iv6').
	self assert: (targetClass instVarNames includes: 'iv6').
	self assert: 'iv6: anObject', String newLineString, String tab, '^iv6 := anObject.' equals: (targetClass compiledMethodAt: #iv6:) sourceCode.
	self assert: 'iv6: anObject
|tmpvar|
iv2 iv6: anObject.
tmpvar := anObject.
iv2 iv6: tmpvar.' equals: (sourceClass compiledMethodAt: #iv6:) sourceCode.

	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'HAW 3/14/2023 12:20:16'!
test13CanMoveInstVarWhenThereAreTwoReadReferencesToSourceIV

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv6'.
	sourceClass compile: 'iv6
|iiiiiiv6|
iiiiiiv6 := 1.
iv6.
^iv6'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRefactoring named: 'iv6' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self assert: 'iv6
|iiiiiiv6|
iiiiiiv6 := 1.
iv2 iv6.
^iv2 iv6' equals: (sourceClass compiledMethodAt: #iv6) sourceCode.
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'HAW 3/14/2023 12:20:16'!
test14CanMoveInstVarWhenThereIsAReadReferencesInAssignation

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv6'.
	sourceClass compile: 'readOnAssign
|tmp|
tmp := iv6 byteAt: 2.
^tmp'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRefactoring named: 'iv6' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self assert: 'readOnAssign
|tmp|
tmp := iv2 iv6 byteAt: 2.
^tmp' equals: (sourceClass compiledMethodAt: #readOnAssign) sourceCode.
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'HAW 3/14/2023 12:20:16'!
test15CanMoveInstVarWhenThereIsAMixedReferencesToSourceIV

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv1 iv2 iv3'.
	sourceClass compile: 'iv1: anObject
	iv1 := iv3 byteAt: 2.
	iv1 := iv1 + 1.
	iv3 := 1.
	^iv3.'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRefactoring named: 'iv1' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self assert: 'iv1: anObject
	iv2 iv1: (iv3 byteAt: 2).
	iv2 iv1: iv2 iv1 + 1.
	iv3 := 1.
	^iv3.' equals: (sourceClass compiledMethodAt: #iv1:) sourceCode.
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'HAW 3/14/2023 12:20:16'!
test16CanMoveInstVarWhenThereIsAMixedReferencesToSourceIV

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv1 iv2 iv3'.
	sourceClass compile: 'iv1: anObject
iv1 := iv1 + 1.
iv3 := 1.
^iv3.'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRefactoring named: 'iv1' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self assert: 'iv1: anObject
iv2 iv1: iv2 iv1 + 1.
iv3 := 1.
^iv3.' equals: (sourceClass compiledMethodAt: #iv1:) sourceCode.
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'HAW 3/14/2023 12:20:16'!
test17SubClassReadMethodsShouldBeRefactored

	| refactoring sourceClass targetClass sourceSuperClass |
	sourceSuperClass := self createClassNamed: #SourceSuperClass instanceVariableNames:'iv6 iv2'.
	sourceClass := self createClassNamed: #SourceClass subclassOf: sourceSuperClass.
	sourceClass compile: 'iv6
	^iv6'.
	sourceSuperClass compile: 'iv6
	^iv6.'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRefactoring named: 'iv6' from: sourceSuperClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self assert: 'iv6
	^iv2 iv6' equals: (sourceClass compiledMethodAt: #iv6) sourceCode.

	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'HAW 3/14/2023 12:20:16'!
test18SubClassWriteMethodsShouldBeRefactored

	| refactoring sourceClass targetClass sourceSuperClass |
	sourceSuperClass := self createClassNamed: #SourceSuperClass instanceVariableNames:'iv6 iv2'.
	sourceClass := self createClassNamed: #SourceClass subclassOf: sourceSuperClass.
	sourceClass compile: 'iv6: anObject
	iv6 := anObject'.
	sourceSuperClass compile: 'iv6: anObject
	iv6 := anObject.'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRefactoring named: 'iv6' from: sourceSuperClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self assert: 'iv6: anObject
	iv2 iv6: anObject' equals: (sourceClass compiledMethodAt: #iv6:) sourceCode.

	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'HAW 3/14/2023 12:20:16'!
test19MixedMethodsShouldBeRefactored

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv5'.
	sourceClass compile: 'iv5
iv5 := 1.
^iv5'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRefactoring named: 'iv5' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self assert: 'iv5', String newLineString, String tab, '^iv5' equals: (targetClass compiledMethodAt: #iv5) sourceCode.
	self assert: 'iv5: anObject', String newLineString, String tab, '^iv5 := anObject.' equals: (targetClass compiledMethodAt: #iv5:) sourceCode.
	self assert: 'iv5
iv2 iv5: 1.
^iv2 iv5' equals: (sourceClass compiledMethodAt: #iv5) sourceCode.
! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'HAW 3/14/2023 12:20:16'!
test20MixedMethodsShouldBeRefactored

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv5'.
	sourceClass compile: 'iv5
| tmp1 |
tmp1 := 1.
iv5 := 1.
^iv5'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRefactoring named: 'iv5' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self assert: 'iv5', String newLineString, String tab, '^iv5' equals: (targetClass compiledMethodAt: #iv5) sourceCode.
	self assert: 'iv5: anObject', String newLineString, String tab, '^iv5 := anObject.' equals: (targetClass compiledMethodAt: #iv5:) sourceCode.
	self assert: 'iv5
| tmp1 |
tmp1 := 1.
iv2 iv5: 1.
^iv2 iv5' equals: (sourceClass compiledMethodAt: #iv5) sourceCode.
! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'HAW 3/14/2023 12:20:16'!
test21MixedMethodsShouldBeRefactoredInSubclass

	| refactoring sourceClass targetClass sourceSuperClass |
	sourceSuperClass := self createClassNamed: #SourceSuperClass instanceVariableNames:'iv2 iv5'.
	sourceClass := self createClassNamed: #SourceClass subclassOf: sourceSuperClass.
	sourceClass compile: 'iv5
| tmp1 |
tmp1 := 1.
iv5 := 1.
^iv5'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRefactoring named: 'iv5' from: sourceSuperClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self assert: 'iv5', String newLineString, String tab, '^iv5' equals: (targetClass compiledMethodAt: #iv5) sourceCode.
	self assert: 'iv5: anObject', String newLineString, String tab, '^iv5 := anObject.' equals: (targetClass compiledMethodAt: #iv5:) sourceCode.
	self assert: 'iv5
| tmp1 |
tmp1 := 1.
iv2 iv5: 1.
^iv2 iv5' equals: (sourceClass compiledMethodAt: #iv5) sourceCode.
! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'HAW 3/14/2023 12:20:16'!
test22WriteMethodsWithSameBlockCodeShouldBeRefactored

	| refactoring sourceClass targetClass |
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames:'iv6 iv2 iv1'.
	sourceClass compile: 'iv6: anObject
iv6 := anObject'.
	sourceClass compile: 'iv66: anObject
iv6 := anObject.'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRefactoring named: 'iv6' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self assert: 'iv6: anObject
iv2 iv6: anObject' equals: (sourceClass compiledMethodAt: #iv6:) sourceCode.
	self assert: 'iv66: anObject
iv2 iv6: anObject.' equals: (sourceClass compiledMethodAt: #iv66:) sourceCode.
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'HAW 3/14/2023 12:20:16'!
test23MoveInstVarWithNoReadReferencesOnIVShouldNotCreateGetterOnTarget

	| refactoring sourceClass targetClass targetMessages |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv1 iv2 iv3'.
	targetClass := self createClassNamed: #TargetClass.
	sourceClass compile: 'iv1: anObject
iv1 := anObject.
iv3 := 1.
^iv3.'.
	
	refactoring := MoveInstanceVariableRefactoring named: 'iv1' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	targetMessages := targetClass methodDictionary keys .
	self deny: (targetMessages includes: #iv1).
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'HAW 3/14/2023 12:20:16'!
test24CanMoveInstVarWhenThereIsAWriteReferencesAndKeywordMessage

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv1 iv2 iv3'.
	sourceClass compile:  
'iv1: anObject
	iv1 := iv3 byteAt: 2.
	iv3 := 1.
	^iv3.'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRefactoring named: 'iv1' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self assert: 'iv1: anObject', String newLineString, String tab, '^iv1 := anObject.' equals: (targetClass compiledMethodAt: #iv1:) sourceCode.
	self assert: 
'iv1: anObject
	iv2 iv1: (iv3 byteAt: 2).
	iv3 := 1.
	^iv3.' equals: (sourceClass compiledMethodAt: #iv1:) sourceCode.
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'HAW 3/14/2023 12:20:16'!
test25ThereAreOnly2VersionsAfterRefactoringMethodWithTwoWriteReferences

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv6'.
	sourceClass compile: self setterWithTwoAssignations.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRefactoring named: 'iv6' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self assert: 2 equals: (VersionsBrowser versionCountForSelector: #iv6: class: sourceClass).! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'HAW 3/14/2023 12:20:16'!
test26ThereAreOnly2VersionsAfterRefactoringMethodWithTwoReadReferences

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv6'.
	sourceClass compile: 'iv6
|iiiiiiv6|
iiiiiiv6 := 1.
iv6.
^iv6'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRefactoring named: 'iv6' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.

	self assert: 2 equals: (VersionsBrowser versionCountForSelector: #iv6 class: sourceClass).
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'HAW 3/14/2023 12:20:16'!
test27ThereAreOnly2VersionsAfterRefactoringMethodWithMixedReferences

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv6'.
	sourceClass compile: 'iv6
| tmp1 |
tmp1 := 1.
iv6 := 1.
^iv6'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRefactoring named: 'iv6' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.

	self assert: 2 equals: (VersionsBrowser versionCountForSelector: #iv6 class: sourceClass).
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'HAW 3/14/2023 12:20:16'!
test28ParenthesisShouldBeUsedOnDoubleAssignation

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv6'.
	sourceClass compile: 'iv6
| tmp1 |
iv6 := tmp1 := 1.'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRefactoring named: 'iv6' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.

	self assert: 'iv6
| tmp1 |
iv2 iv6: (tmp1 := 1).' equals: (sourceClass compiledMethodAt: #iv6) sourceCode.
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'HAW 3/14/2023 12:20:16'!
test29ParenthesisShouldBeUsedOnDoubleAssignation

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv6'.
	sourceClass compile: 'iv6
| tmp1 |
iv6 := iv6 := 1.'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRefactoring named: 'iv6' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.

	self assert: 'iv6
| tmp1 |
iv2 iv6: (iv2 iv6: 1).' equals: (sourceClass compiledMethodAt: #iv6) sourceCode.
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'HAW 3/14/2023 12:20:16'!
test30ParenthesisShouldBeUsedOnDoubleAssignationAndCodeRepetition

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv6'.
	sourceClass compile: 'iv6
	| tmp1 |
	tmp := 1.
	iv6 := iv6 := iv6 byteAt: tmp.
	tmp := iv6 := iv6 byteAt: tmp.
	^tmp.'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRefactoring named: 'iv6' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.

	self assert: 'iv6
	| tmp1 |
	tmp := 1.
	iv2 iv6: (iv2 iv6: (iv2 iv6 byteAt: tmp)).
	tmp := iv2 iv6: (iv2 iv6 byteAt: tmp).
	^tmp.' equals: (sourceClass compiledMethodAt: #iv6) sourceCode.
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'HAW 3/14/2023 12:20:16'!
test31CodeRepeatedInClousureShouldBeRefactored_oneReadAccessVersion

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv6'.
	sourceClass compile: 'accessIv6
	iv6 _ [
		iv6 _ [iv6+ 1]. 
		iv6 _ [iv6+ 1]
		]'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRefactoring named: 'iv6' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.

	self assert: 'accessIv6
	iv2 iv6: [
		iv2 iv6: [iv2 iv6+ 1]. 
		iv2 iv6: [iv2 iv6+ 1]
		]' equals: (sourceClass compiledMethodAt: #accessIv6) sourceCode.
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'HAW 3/14/2023 12:20:16'!
test32CodeRepeatedInClousureShouldBeRefactored_twoReadAceessVersion

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv1 iv2'.
	sourceClass compile: 'accessIv1
	iv1 _ [
		iv1 _ [iv1 + iv1]. 
		iv1 _ [iv1 + iv1]
		]'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRefactoring named: 'iv1' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.

	self assert: 'accessIv1
	iv2 iv1: [
		iv2 iv1: [iv2 iv1 + iv2 iv1]. 
		iv2 iv1: [iv2 iv1 + iv2 iv1]
		]' equals: (sourceClass compiledMethodAt: #accessIv1) sourceCode.
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'HAW 3/14/2023 12:20:16'!
test33CodeRepeatedInClousureShouldBeRefactored_assingn

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv1 iv2'.
	sourceClass compile: 'accessIv1
	iv1 _ [
		iv1 _ [iv1 + iv1]. 
		iv1 _ [ iv1 _ [iv1 + iv1] ]
		]'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRefactoring named: 'iv1' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.

	self assert: 'accessIv1
	iv2 iv1: [
		iv2 iv1: [iv2 iv1 + iv2 iv1]. 
		iv2 iv1: [ iv2 iv1: [iv2 iv1 + iv2 iv1] ]
		]' equals: (sourceClass compiledMethodAt: #accessIv1) sourceCode.
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'HAW 3/14/2023 12:20:16'!
test34CodeWithDiferentStructureInClousureShouldBeRefactored

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv1 iv2'.
	sourceClass compile: 'accessIv1
	iv1 _ [
		iv1 _ [iv1   +   iv1].
		iv1 _ [iv1 _ [iv1+iv1]]. 
		]'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRefactoring named: 'iv1' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.

	self assert: 'accessIv1
	iv2 iv1: [
		iv2 iv1: [iv2 iv1   +   iv2 iv1].
		iv2 iv1: [iv2 iv1: [iv2 iv1+iv2 iv1]]. 
		]' equals: (sourceClass compiledMethodAt: #accessIv1) sourceCode.
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 11/7/2023 23:55:01'!
test36_validation_getterMessageShouldntExistsOnTarget

	| sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv1 iv2'.
	sourceClass compile: 'methodReadsIv1
^iv1'.
	targetClass := self createClassNamed: #TargetClass.
	targetClass compile: 'getterIv1
^5'.
	
	self 
		assertCreation: [MoveInstanceVariableRefactoring named: 'iv1' from: sourceClass to: targetClass accessingThrough: 'iv2'  usingGetter: #getterIv1 usingSetter: #setterIv1:]
		failsWith: [MoveInstanceVariableRefactoring getterExistsOnTargetHierarchyErrorMessage].
	

	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 11/7/2023 23:55:01'!
test37_validation_getterMessageShouldntExistsOnTarget

	| sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv3'.
	sourceClass compile: 'methodReadsIv1
^iv2'.
	targetClass := self createClassNamed: #TargetClass.
	targetClass compile: 'getterIv2
^5'.
	
	self 
		assertCreation: [MoveInstanceVariableRefactoring named: 'iv2' from: sourceClass to: targetClass accessingThrough: 'iv3'  usingGetter: #getterIv2 usingSetter: #setterIv2:] 
		failsWith: [MoveInstanceVariableRefactoring getterExistsOnTargetHierarchyErrorMessage].
	

	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 11/7/2023 23:55:01'!
test38_validation_getterMessageShouldntExistsOnTargetSuperclass

	| sourceClass targetClass targetSuperClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv3'.
	sourceClass compile: 'methodReadsIv1
^iv2'.
	targetSuperClass := self createClassNamed: #TargetSuperClass .
	targetSuperClass compile: 'getterIv2
^5'.	
	targetClass := self createClassNamed: #TargetClass subclassOf: targetSuperClass.

	self
		assertCreation: [MoveInstanceVariableRefactoring named: 'iv2' from: sourceClass to: targetClass accessingThrough: 'iv3'  usingGetter: #getterIv2 usingSetter: #setterIv2:] 
		failsWith: [MoveInstanceVariableRefactoring getterExistsOnTargetHierarchyErrorMessage].
	

	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'HAW 3/14/2023 12:20:16'!
test39_validation_instanceVariableShouldntExistsOnTarget

	| sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv3'.
	targetClass := self createClassNamed: #TargetClass instanceVariableNames: 'iv2'.
	
	self
		assertCreation: [MoveInstanceVariableRefactoring named: 'iv2' from: sourceClass to: targetClass accessingThrough: 'iv3'] 
		failsWith: [MoveInstanceVariableRefactoring instanceVariableExistsOnTargetHierarchyErrorMessage].
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'HAW 3/14/2023 12:20:16'!
test40_validation_instanceVariableShouldntExistsOnTargetSubclass

	| sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv3'.
	targetClass := self createClassNamed: #TargetClass.
	self createClassNamed: #TargetSubClass subclassOf: targetClass instanceVariableNames: 'iv2'.
	
	self
		assertCreation: [MoveInstanceVariableRefactoring named: 'iv2' from: sourceClass to: targetClass accessingThrough: 'iv3'] 
		failsWith: [MoveInstanceVariableRefactoring instanceVariableExistsOnTargetHierarchyErrorMessage].
	

	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 11/7/2023 23:54:36'!
test41_validation_setterMessageShouldntExistsOnTarget

	| sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv1 iv2'.
	sourceClass compile: 'methodWritesIv1
^iv1 := 1'.
	targetClass := self createClassNamed: #TargetClass.
	targetClass compile: 'setterIv1: anObject
^anObject + 5'.
	
	self
		assertCreation: [MoveInstanceVariableRefactoring named: 'iv1' from: sourceClass to: targetClass accessingThrough: 'iv2'  usingGetter: #getterIv1 usingSetter: #setterIv1:] 
		failsWith: [MoveInstanceVariableRefactoring setterExistsOnTargetHierarchyErrorMessage].
	

	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'HAW 3/14/2023 12:20:16'!
test42_instanceVariableToAccessThroughShouldExistsOnSourceHierarchy

	| sourceClass targetClass sourceSuperClass refactoring |
	
	sourceSuperClass := self createClassNamed: #SourceSuperClass instanceVariableNames: 'iv2'.
	sourceClass := self createClassNamed: #SourceClass subclassOf: sourceSuperClass instanceVariableNames: 'iv1'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRefactoring named: 'iv1' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self deny: (sourceClass instVarNames includes: 'iv1').
	self assert: (targetClass instVarNames includes: 'iv1').
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'HAW 3/14/2023 12:20:16'!
test42_validation_instanceVariableToMoveShouldExistsOnSource

	| sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2'.
	targetClass := self createClassNamed: #TargetClass.
	
	self
		assertCreation: [MoveInstanceVariableRefactoring named: 'iv1' from: sourceClass to: targetClass accessingThrough: 'iv2'] 
		failsWith: [MoveInstanceVariableRefactoring instanceVariableToMoveShouldExistOnSourceClassErrorMessage].
		! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'HAW 3/14/2023 12:20:16'!
test43_validation_instanceVariableToAccessThroughShouldExistsOnSource

	| sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv1'.
	targetClass := self createClassNamed: #TargetClass.
	
	self
		assertCreation: [MoveInstanceVariableRefactoring named: 'iv1' from: sourceClass to: targetClass accessingThrough: 'iv2'] 
		failsWith: [MoveInstanceVariableRefactoring instanceVariableToAccessThroughShouldExistOnSourceClassErrorMessage].
		! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'HAW 3/14/2023 12:20:16'!
test44_validation_souceclassAndTargetClassCanNotBeTheSame

	| sourceClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv3'.
	
	self
		assertCreation: [MoveInstanceVariableRefactoring named: 'iv2' from: sourceClass to: sourceClass accessingThrough: 'iv3'] 
		failsWith: [MoveInstanceVariableRefactoring souceClassAndTargetClassCanNotBeTheSameErrorMessage].
		! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'HAW 3/14/2023 12:20:16'!
test45_validation_targetClassCanNotBeSuperClassOfSourceClass

	| sourceClass targetClass |
	
	targetClass := self createClassNamed: #TargetSubClass.
	sourceClass := self createClassNamed: #SourceClass subclassOf: targetClass instanceVariableNames: 'iv2 iv3'.
	
	self
		assertCreation: [MoveInstanceVariableRefactoring named: 'iv2' from: sourceClass to: targetClass accessingThrough: 'iv3'] 
		failsWith: [MoveInstanceVariableRefactoring targetClassCanNotBeSuperClassOfSourceClassErrorMessage].! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'HAW 3/14/2023 12:20:16'!
test46_validation_targetClassCanNotBeSubClassOfSourceClass

	| sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass  instanceVariableNames: 'iv2 iv3'.
	targetClass := self createClassNamed: #TargetSubClass subclassOf: sourceClass.
	
	self
		assertCreation: [MoveInstanceVariableRefactoring named: 'iv2' from: sourceClass to: targetClass accessingThrough: 'iv3'] 
		failsWith: [MoveInstanceVariableRefactoring targetClassCanNotBeSubClassOfSourceClassErrorMessage].
		! !

!MoveInstanceVariableRefactoring methodsFor: 'initialization' stamp: 'mc 11/7/2023 03:17:49'!
initializeNamed: anInstVarNameSourceClass from: aSourceClass to: aTargetClass accessingThrough: anInstVarNameTargetClass usingGetter: aGetterSelector usingSetter: aSetterSelector 
	instVarNameSourceClass := anInstVarNameSourceClass.
	sourceClass := aSourceClass.
	targetClass := aTargetClass.
	instVarNameTargetClass := anInstVarNameTargetClass.
	modifiedReads := 0.
	modifiedWrites := 0.
	getterToUse := aGetterSelector.
	setterToUse := aSetterSelector! !

!MoveInstanceVariableRefactoring methodsFor: 'applying' stamp: 'mc 3/8/2023 00:50:38'!
apply
	self replaceAccessInSourceClass.
	targetClass addInstVarName: instVarNameSourceClass.
	sourceClass removeInstVarName: instVarNameSourceClass.
	modifiedReads = 0 ifFalse: [ self createGetterOnTargetClass ].
	modifiedWrites = 0 ifFalse: [ self createSetterOnTargetClass ].! !

!MoveInstanceVariableRefactoring methodsFor: 'private' stamp: 'mc 3/8/2023 00:44:06'!
accessInSourceClass
	| accessMethods |
	accessMethods := OrderedCollection new.
	sourceClass withAllSubclassesDo: [ :aSubClass | | selectorsAccessingIV | 
		selectorsAccessingIV := (aSubClass whichSelectorsAccess: instVarNameSourceClass) asOrderedCollection .
		accessMethods addAll: ( selectorsAccessingIV collect: [ :aSelector | aSubClass methodDict at: aSelector ])
		].
	^ accessMethods! !

!MoveInstanceVariableRefactoring methodsFor: 'private' stamp: 'mc 3/24/2023 00:44:36'!
compileSource: sourceCode on: aTargetClass 
	^ aTargetClass 
		compile: sourceCode
		classified: self class getterSetterCategoryName ! !

!MoveInstanceVariableRefactoring methodsFor: 'private' stamp: 'mc 11/7/2023 01:12:45'!
createGetterOnTargetClass
	^self 
		compileSource: getterToUse, String newLineString, String tab, '^', instVarNameSourceClass 
		on: targetClass 
! !

!MoveInstanceVariableRefactoring methodsFor: 'private' stamp: 'mc 11/7/2023 22:51:52'!
createSetterOnTargetClass
	^self 
		compileSource: setterToUse , ' anObject', String newLineString, String tab, '^', instVarNameSourceClass, ' := anObject.' 
		on: targetClass.! !

!MoveInstanceVariableRefactoring methodsFor: 'private' stamp: 'mc 11/7/2023 22:43:18'!
replaceAccessInSourceClass
	| newSource result |
	self accessInSourceClass do: [ :aMethod | | replacer |
		 replacer := CodeForNodeOnMethod 
			replace: instVarNameSourceClass 
			onMethod: aMethod 
			accessingThrough: instVarNameTargetClass
			usingGetter: getterToUse
			usingSetter: setterToUse .
		result := replacer value.
		newSource := result resultCode.
		aMethod methodClass compile: newSource.
		modifiedReads := modifiedReads + result modifiedReads.
		modifiedWrites := modifiedWrites + result modifiedWrites.
		]! !

!MoveInstanceVariableRefactoring class methodsFor: 'error messages' stamp: 'mc 11/7/2023 23:55:01'!
getterExistsOnTargetHierarchyErrorMessage

	^ 'getter exists on target hierarchy'! !

!MoveInstanceVariableRefactoring class methodsFor: 'error messages' stamp: 'mc 12/22/2022 19:24:26'!
instanceVariableExistsOnTargetHierarchyErrorMessage

	^ 'instance variable exists on target hierarchy'! !

!MoveInstanceVariableRefactoring class methodsFor: 'error messages' stamp: 'mc 12/22/2022 22:24:11'!
instanceVariableToAccessThroughShouldExistOnSourceClassErrorMessage
	^'instance variable to access through does not exists on source class'.! !

!MoveInstanceVariableRefactoring class methodsFor: 'error messages' stamp: 'mc 12/22/2022 22:19:08'!
instanceVariableToMoveShouldExistOnSourceClassErrorMessage
	^'instance variable does not exists on source class'.! !

!MoveInstanceVariableRefactoring class methodsFor: 'error messages' stamp: 'mc 11/7/2023 23:54:36'!
setterExistsOnTargetHierarchyErrorMessage
	^'setter exists on target hierarchy'! !

!MoveInstanceVariableRefactoring class methodsFor: 'error messages' stamp: 'mc 1/12/2023 23:09:23'!
souceClassAndTargetClassCanNotBeTheSameErrorMessage
	^'source class and target class can not be the same'.! !

!MoveInstanceVariableRefactoring class methodsFor: 'error messages' stamp: 'mc 1/12/2023 23:29:42'!
targetClassCanNotBeSubClassOfSourceClassErrorMessage
	^'Target class can not be sub class of source class. Use push-down refactoring'! !

!MoveInstanceVariableRefactoring class methodsFor: 'error messages' stamp: 'mc 1/12/2023 23:25:12'!
targetClassCanNotBeSuperClassOfSourceClassErrorMessage
	^'Target class can not be super class of source class. Use push-up refactoring'! !

!MoveInstanceVariableRefactoring class methodsFor: 'instance creation' stamp: 'mc 11/7/2023 01:19:28'!
named: instVarNameSourceClass from: sourceClass to: targetClass accessingThrough: instVarNameTargetClass 
	^self 
		named: instVarNameSourceClass
		from: sourceClass
		to: targetClass
		accessingThrough: instVarNameTargetClass
		usingGetter: instVarNameSourceClass asSymbol.! !

!MoveInstanceVariableRefactoring class methodsFor: 'instance creation' stamp: 'mc 11/7/2023 22:54:18'!
named: instVarNameSourceClass from: sourceClass to: targetClass accessingThrough: instVarNameTargetClass  usingGetter: aGetterSelector 

	^self  
		named: instVarNameSourceClass
		from: sourceClass
		to: targetClass
		accessingThrough: instVarNameTargetClass
		usingGetter: aGetterSelector 
		usingSetter: (instVarNameSourceClass, ':') asSymbol ! !

!MoveInstanceVariableRefactoring class methodsFor: 'instance creation' stamp: 'mc 11/7/2023 23:55:01'!
named: instVarNameSourceClass from: sourceClass to: targetClass accessingThrough: instVarNameTargetClass  usingGetter: aGetterSelector usingSetter: aSetterSelector 

	(sourceClass = targetClass) ifTrue: [ self refactoringError: self souceClassAndTargetClassCanNotBeTheSameErrorMessage ].
	(targetClass allSubclasses includes: sourceClass) ifTrue: [ self refactoringError: self targetClassCanNotBeSuperClassOfSourceClassErrorMessage ].
	(sourceClass allSubclasses includes: targetClass) ifTrue: [ self refactoringError: self targetClassCanNotBeSubClassOfSourceClassErrorMessage ].
	(targetClass allSelectors includes: aGetterSelector) ifTrue: [ self refactoringError: self getterExistsOnTargetHierarchyErrorMessage ].
	(targetClass allInstVarNamesEverywhere includes: instVarNameSourceClass) ifTrue: [ self refactoringError: self instanceVariableExistsOnTargetHierarchyErrorMessage ].
	(targetClass allSelectors includes: aSetterSelector) ifTrue: [ self refactoringError: self setterExistsOnTargetHierarchyErrorMessage ].
	(sourceClass instVarNames includes: instVarNameSourceClass) ifFalse: [ self refactoringError: self instanceVariableToMoveShouldExistOnSourceClassErrorMessage ].
	(sourceClass allInstVarNames includes: instVarNameTargetClass) ifFalse: [ self refactoringError: self instanceVariableToAccessThroughShouldExistOnSourceClassErrorMessage ].

	^self new initializeNamed: instVarNameSourceClass from: sourceClass to: targetClass accessingThrough: instVarNameTargetClass usingGetter: aGetterSelector usingSetter: aSetterSelector ! !

!MoveInstanceVariableRefactoring class methodsFor: 'category name' stamp: 'mc 3/24/2023 00:38:06'!
getterSetterCategoryName
	^'getter-setter'! !

!MoveInstanceVariableApplier methodsFor: 'refactoring - parameters request' stamp: 'mc 12/11/2023 18:21:30'!
askTargetClassName
	| targetClassNameTmp initialAnswer |
	initialAnswer := self initialAnswerForInstanceVariable: accessingThroughinstanceVariableName in: classToRefactor.
	targetClassNameTmp := ClassNameRequestMorph request: 'Enter target class name:' initialAnswer: initialAnswer orCancel: requestExitBlock.
	"self halt."
	targetClassNameTmp := targetClassNameTmp withoutSeparators.
	targetClass := Smalltalk at: targetClassNameTmp asSymbol ifAbsent: [Refactoring refactoringErrorClass signal: 'Cant find the target class'].! !

!MoveInstanceVariableApplier methodsFor: 'refactoring - parameters request' stamp: 'mc 2/3/2023 00:18:03'!
chooseInstanceVariableToAccessThrough
	| vars index |
	"self halt."
	vars _ classToRefactor allInstVarNames sorted.
	vars _ vars reject: [ :anInstanceVariable | anInstanceVariable = instanceVariableName ].
	vars isEmpty ifTrue: [Refactoring refactoringErrorClass signal: 'There is no instance variable to access through' ].
	
	index _ (PopUpMenu labelArray: vars lines: #()) startUpWithCaption: self selectVariableLabel.
	index = 0 ifTrue: [^self endRequest].
	accessingThroughinstanceVariableName := vars at: index.! !

!MoveInstanceVariableApplier methodsFor: 'refactoring - parameters request' stamp: 'mc 1/22/2023 02:07:44'!
chooseInstanceVariableToMove
	instanceVariableName ifNotNil: [ ^self ].
	
	classToRefactor 
		chooseDefiningInstanceVariableAlphabeticallyWith: self selectVariableToMoveLabel
		thenDo: [ :anInstanceVariable | ^instanceVariableName := anInstanceVariable ].
		
	self endRequest ! !

!MoveInstanceVariableApplier methodsFor: 'refactoring - parameters request' stamp: 'HAW 3/14/2023 12:20:16'!
createRefactoring
	^MoveInstanceVariableRefactoring 
		named: instanceVariableName 
		from: classToRefactor 
		to: targetClass
		accessingThrough: accessingThroughinstanceVariableName.! !

!MoveInstanceVariableApplier methodsFor: 'refactoring - parameters request' stamp: 'mc 12/11/2023 18:21:54'!
initialAnswerForInstanceVariable: anAccessingThroughinstanceVariableName in: aSourceClass 
	
	^''! !

!MoveInstanceVariableApplier methodsFor: 'refactoring - parameters request' stamp: 'mc 2/7/2023 23:44:01'!
requestRefactoringParameters

	self 
		chooseInstanceVariableToMove;
		selectClassWichInstaceVariableIsDefined;
		chooseInstanceVariableToAccessThrough;
		askTargetClassName! !

!MoveInstanceVariableApplier methodsFor: 'refactoring - parameters request' stamp: 'mc 2/9/2023 23:33:52'!
selectClassWichInstaceVariableIsDefined
	| classToRefactorWithIVDefined |
	"self halt."
	classToRefactorWithIVDefined := classToRefactor whichClassDefinesInstanceVariable: instanceVariableName ifNone: [Refactoring refactoringErrorClass signal: 'Instance variable ', instanceVariableName, ' does not exist in ', targetClass name, ' herarchy'].
	classToRefactorWithIVDefined = classToRefactor ifFalse: [ 
		Refactoring refactoringWarning: 'Instance variable ', instanceVariableName, ' is not defined on class ', classToRefactor name.
		classToRefactor := classToRefactorWithIVDefined ]! !

!MoveInstanceVariableApplier methodsFor: 'refactoring - parameters request' stamp: 'mc 1/5/2023 18:23:52'!
selectVariableLabel
	^'Select variable to access through'! !

!MoveInstanceVariableApplier methodsFor: 'refactoring - parameters request' stamp: 'mc 1/22/2023 02:08:37'!
selectVariableToMoveLabel
	^'Choose instance variable to move'! !

!MoveInstanceVariableApplier class methodsFor: 'as yet unclassified' stamp: 'mc 12/11/2023 18:53:31'!
initialize
	(Smalltalk classNamed: #LiveTyping) ifNotNil: [
		RefactoringApplier 
			registerMoveInstanceVariableApplier: MoveInstanceVariableWithActualScopeApplier .
	].! !

!MoveInstanceVariableWithActualScopeApplier methodsFor: 'as yet unclassified' stamp: 'mc 1/6/2024 03:35:50'!
initialAnswerForInstanceVariable: anAccessingThroughinstanceVariableName in: aSourceClass 
	
	| liveTypingTypes |
	"self halt."
	classToRefactor shouldLiveTypingBeDisabled 
		ifTrue: [^'']
		ifFalse: [
			liveTypingTypes := classToRefactor commonSupertypeOfInstanceVariableNamed: accessingThroughinstanceVariableName ifNoTypes: [^''].
			"((liveTypingTypes types includes: UndefinedObject) or: [liveTypingTypes types isEmpty]) ifTrue: [^''].
			^liveTypingTypes commonSupertype name asString "
			^liveTypingTypes name asString 
		]! !

!CodeForNodeResult methodsFor: 'as yet unclassified' stamp: 'mc 3/7/2023 01:58:49'!
initielizeWith: newCode modifiedReads: anAmountOfModifiedReads modifiedWrites: anAmountOfModifiedWrites
	modifiedReads := anAmountOfModifiedReads .
	modifiedWrites  := anAmountOfModifiedWrites .
	resultCode := newCode .! !

!CodeForNodeResult methodsFor: 'as yet unclassified' stamp: 'mc 3/7/2023 01:59:25'!
modifiedReads
	^modifiedReads ! !

!CodeForNodeResult methodsFor: 'as yet unclassified' stamp: 'mc 3/7/2023 01:59:44'!
modifiedWrites
	^modifiedWrites ! !

!CodeForNodeResult methodsFor: 'as yet unclassified' stamp: 'mc 3/7/2023 02:00:20'!
resultCode
	^resultCode ! !

!CodeForNodeResult class methodsFor: 'instance creation' stamp: 'mc 3/7/2023 01:57:01'!
newWith: newCode modifiedReads: modifiedReads modifiedWrites: modifiedWrites
	^self new initielizeWith: newCode modifiedReads: modifiedReads modifiedWrites: modifiedWrites! !

!TesisRefactoringMenu class methodsFor: 'as yet unclassified' stamp: 'mc 2/7/2023 01:42:04'!
classListMenuOptions

	^ `{	
			{
				#submenuOf -> RefactoringMenues refactoringsLabel.
				#itemGroup 		-> 		20.
				#itemOrder 		-> 		70.
				#label 			-> 		'move inst var...'.
				#selector 		-> 		#contextualMoveInstanceVariable.
				#icon 			-> 		#saveAsIcon
			} asDictionary.			
	}`.
	! !

!TesisRefactoringMenu class methodsFor: 'as yet unclassified' stamp: 'mc 7/18/2023 00:27:32'!
smalltalkEditorCmdShortcutsSpec
	"
	SmalltalkEditor initializeCmdShortcuts
	"
	^#(
		#($Y	#contextualMoveInstanceVariable:						'Move instance variable what is under cursor')
	)! !

!TesisRefactoringMenu class methodsFor: 'as yet unclassified' stamp: 'mc 2/7/2023 01:13:53'!
smalltalkEditorMenuOptions

	^`{
		{
				#submenuOf -> RefactoringMenues refactoringsLabel.
				#itemGroup 		-> 		40.
				#itemOrder 		-> 		40.
				#label 			-> 		'Move Instance Variable'.
				#selector 		-> 		#contextualMoveInstanceVariable.
				#icon 			-> 		#saveAsIcon
		} asDictionary.
	}`! !

!SmalltalkEditor methodsFor: '*MoveInstanceVariableRefactoring' stamp: 'mc 2/13/2023 19:08:22'!
contextualMoveInstanceVariable
	"self halt."
	self isEditingClassDefinition 
		ifTrue: [ self contextualMoveInstanceVariableInClassDefinition ]
		ifFalse: [ self contextualMoveInstanceVariableInMethod ].
	! !

!SmalltalkEditor methodsFor: '*MoveInstanceVariableRefactoring' stamp: 'mc 1/21/2023 14:29:32'!
contextualMoveInstanceVariable: aKeyboardEvent
	self contextualMoveInstanceVariable.
	^true! !

!SmalltalkEditor methodsFor: '*MoveInstanceVariableRefactoring' stamp: 'mc 1/9/2023 23:33:58'!
contextualMoveInstanceVariableInClassDefinition 

	self ifSourceCodeRefactoringCanBeAppliedDo: [
		self
			withClassDefinitionNodeAndClassDo: [ :classDefinitionNode :selectedClass | 
				self contextualMoveInstanceVariableInClassDefinitionOf: classDefinitionNode in: selectedClass]
			ifErrorsParsing: [ :anError | morph flash ] ]! !

!SmalltalkEditor methodsFor: '*MoveInstanceVariableRefactoring' stamp: 'mc 1/22/2023 14:44:48'!
contextualMoveInstanceVariableInClassDefinitionOf: aClassDefinitionNode in: aSelectedClass 
	
	| analyzer cursorPosition |
	
	analyzer := ClassDefinitionNodeAnalyzer for: aClassDefinitionNode.
	cursorPosition := self startIndex.
	
	(analyzer isAtInstanceVariables: cursorPosition) 
		ifTrue: [ |selection variableToMove|
			selection := self selectedString.
			variableToMove := selection isEmpty ifTrue: [ self wordUnderCursor ] ifFalse: [ selection ].
			^self moveInstanceVariableOn: self codeProvider for: variableToMove at: aSelectedClass ].
		
	(analyzer isAtClassName: cursorPosition)
		ifTrue: [ ^self moveInstanceVariableOn: self codeProvider at: aSelectedClass ].
	
	morph flash
	! !

!SmalltalkEditor methodsFor: '*MoveInstanceVariableRefactoring' stamp: 'mc 1/5/2023 00:00:28'!
contextualMoveInstanceVariableInMethod
	self
		withMethodNodeAndClassDo: [ :methodNode :selectedClass | self contextualMoveInstanceVariableOf: methodNode in: selectedClass ]
		ifErrorsParsing: [ :anError | morph flash ]		! !

!SmalltalkEditor methodsFor: '*MoveInstanceVariableRefactoring' stamp: 'mc 1/8/2023 02:33:14'!
contextualMoveInstanceVariableOf: aMethodNode in: aSelectedClass

	aMethodNode
		withParseNodeIncluding: self startIndex
		do: [ :nodeUnderCursor | self moveInstanceVariable: nodeUnderCursor in: aSelectedClass at: aMethodNode ]
		ifAbsent: [
			self startIndex <= aMethodNode selectorLastPosition
				ifFalse: [ morph flash ]]! !

!SmalltalkEditor methodsFor: '*MoveInstanceVariableRefactoring' stamp: 'mc 1/8/2023 02:34:44'!
moveInstanceVariable: aNodeUnderCursor in: aSelectedClass at: aMethodNode

	aNodeUnderCursor isTempOrArg ifTrue: [ ^morph flash ].

	self ifSourceCodeRefactoringCanBeAppliedDo: [
		aNodeUnderCursor isInstanceVariableNode 
			ifTrue: [^self moveInstanceVariableOn: self codeProvider for: aNodeUnderCursor name at: aSelectedClass ]
			ifFalse: [^morph flash]. ]! !

!SmalltalkEditor methodsFor: '*MoveInstanceVariableRefactoring' stamp: 'mc 1/22/2023 14:43:10'!
moveInstanceVariableOn: aBrowser at: aClassToRefactor
	self moveInstanceVariableOn: aBrowser for: nil at: aClassToRefactor.! !

!SmalltalkEditor methodsFor: '*MoveInstanceVariableRefactoring' stamp: 'mc 12/11/2023 02:04:43'!
moveInstanceVariableOn: aBrowser for: anInstanceVariableName at: aClassToRefactor
	"self halt."
	(RefactoringApplier moveInstanceVariableApplier on: aBrowser for: anInstanceVariableName at: aClassToRefactor) value! !

!BrowserWindow methodsFor: '*MoveInstanceVariableRefactoring' stamp: 'mc 12/11/2023 02:06:42'!
contextualMoveInstanceVariable
"self halt."
	model selectedClassOrMetaClass ifNotNil: [ :aClass |
		(RefactoringApplier moveInstanceVariableApplier on: model at: aClass ) value].! !

!RefactoringApplier class methodsFor: '*MoveInstanceVariableRefactoring' stamp: 'mc 12/11/2023 01:54:26'!
moveInstanceVariableApplier
	"self halt."
	^self applierAt: self moveInstanceVariableApplierId ifAbsent: [ MoveInstanceVariableApplier ]! !

!RefactoringApplier class methodsFor: '*MoveInstanceVariableRefactoring' stamp: 'mc 12/11/2023 01:55:07'!
moveInstanceVariableApplierId
	
	^#moveInstanceVariableApplier! !

!RefactoringApplier class methodsFor: '*MoveInstanceVariableRefactoring' stamp: 'mc 12/11/2023 01:57:01'!
registerMoveInstanceVariableApplier: aMoveInstanceVariableApplierClass

	self registerApplierAt: self moveInstanceVariableApplierId with: aMoveInstanceVariableApplierClass! !
MoveInstanceVariableApplier initialize!
