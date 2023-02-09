'From Cuis 6.0 [latest update: #5655] on 8 February 2023 at 1:29:51 am'!
'Description '!
!provides: 'MoveInstanceVariableRefactoring' 1 13!
SystemOrganization addCategory: 'MoveInstanceVariableRefactoring'!


!classDefinition: #CodeForNodeOnMethod category: 'MoveInstanceVariableRefactoring'!
ParseNodeVisitor subclass: #CodeForNodeOnMethod
	instanceVariableNames: 'instanceVariableName compiledMethod rangesToKeywords methodNode instVarNameTargetClass node rangesForAssignNode newAssignCode offsetNodeCodeReplacer'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'MoveInstanceVariableRefactoring'!
!classDefinition: 'CodeForNodeOnMethod class' category: 'MoveInstanceVariableRefactoring'!
CodeForNodeOnMethod class
	instanceVariableNames: ''!

!classDefinition: #InstanceVariableMixedReplacerVisitor category: 'MoveInstanceVariableRefactoring'!
ParseNodeVisitor subclass: #InstanceVariableMixedReplacerVisitor
	instanceVariableNames: 'instanceVariableName compiledMethod rangesToKeywords methodNode instVarNameTargetClass'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'MoveInstanceVariableRefactoring'!
!classDefinition: 'InstanceVariableMixedReplacerVisitor class' category: 'MoveInstanceVariableRefactoring'!
InstanceVariableMixedReplacerVisitor class
	instanceVariableNames: ''!

!classDefinition: #InstanceVariableReaderFinderVisitor category: 'MoveInstanceVariableRefactoring'!
ParseNodeVisitor subclass: #InstanceVariableReaderFinderVisitor
	instanceVariableNames: 'result instanceVariableName'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'MoveInstanceVariableRefactoring'!
!classDefinition: 'InstanceVariableReaderFinderVisitor class' category: 'MoveInstanceVariableRefactoring'!
InstanceVariableReaderFinderVisitor class
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

!classDefinition: #MoveInstanceVariableApplier category: 'MoveInstanceVariableRefactoring'!
TransferInstanceVariableApplier subclass: #MoveInstanceVariableApplier
	instanceVariableNames: 'accessingThroughinstanceVariableName targetClass'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'MoveInstanceVariableRefactoring'!
!classDefinition: 'MoveInstanceVariableApplier class' category: 'MoveInstanceVariableRefactoring'!
MoveInstanceVariableApplier class
	instanceVariableNames: ''!

!classDefinition: #MoveInstanceVariableRectoring category: 'MoveInstanceVariableRefactoring'!
Object subclass: #MoveInstanceVariableRectoring
	instanceVariableNames: 'instVarNameSourceClass sourceClass targetClass instVarNameTargetClass'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'MoveInstanceVariableRefactoring'!
!classDefinition: 'MoveInstanceVariableRectoring class' category: 'MoveInstanceVariableRefactoring'!
MoveInstanceVariableRectoring class
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


!TesisRefactoringMenu commentStamp: '<historical>' prior: 0!
Please remove this class after integration!

!CodeForNodeOnMethod methodsFor: 'initialization' stamp: 'mc 1/24/2023 20:13:59'!
initializeFor: aNode replace: instVarNameToReplace onMethod: aCompiledMethod accessingThrough: instVarNameToUseAsReceiver 
	node := aNode.
	instanceVariableName := instVarNameToReplace.
	compiledMethod := aCompiledMethod.
	instVarNameTargetClass := instVarNameToUseAsReceiver.
	methodNode := compiledMethod methodNode.
	rangesToKeywords := OrderedCollection new.! !

!CodeForNodeOnMethod methodsFor: 'visiting' stamp: 'mc 12/27/2022 14:16:21'!
visitAssignmentNode: anAssignmentNode 
| rangesOfassigmentNode assigmentValue newAssignmentCode completeRangesOfassigmentNode newCodeForValue nodeReplacer |

	anAssignmentNode variable name = instanceVariableName ifFalse: [^self].
	
	completeRangesOfassigmentNode := methodNode completeSourceRangesOf: anAssignmentNode ifAbsent: [].
	completeRangesOfassigmentNode removeAllFoundIn: (rangesToKeywords collect: [ :anAssociation | anAssociation key]).
	rangesOfassigmentNode := completeRangesOfassigmentNode detectMin: [ :anInterval | anInterval first].
	nodeReplacer := CodeForNodeOnMethod for: anAssignmentNode value replace: instanceVariableName onMethod: compiledMethod accessingThrough: instVarNameTargetClass.
	newCodeForValue := nodeReplacer execute.
	(((anAssignmentNode value isMessageNode and: [anAssignmentNode value isKeywordMessageSend])) or: [anAssignmentNode value isAssignmentNode ])
		ifTrue: [assigmentValue := '(', newCodeForValue, ')'.] 
		ifFalse: [assigmentValue := newCodeForValue.].
	newAssignmentCode := instVarNameTargetClass, ' ', instanceVariableName, ': ', assigmentValue.
	rangesOfassigmentNode := rangesOfassigmentNode - offsetNodeCodeReplacer.
	rangesToKeywords add: rangesOfassigmentNode -> newAssignmentCode.! !

!CodeForNodeOnMethod methodsFor: 'visiting' stamp: 'mc 12/27/2022 14:03:45'!
visitInstanceVariableNode: anInstanceVariableNode 
	| completeRangesOfassigmentNode newReadWithGetterCode rangesOfInstVarNameSourceClass rangesOfInstVarNameOnNode |
	"self halt."
	anInstanceVariableNode name = instanceVariableName ifFalse: [^self].
	completeRangesOfassigmentNode := methodNode completeSourceRangesOf: anInstanceVariableNode ifAbsent: [].
	rangesOfInstVarNameSourceClass := (completeRangesOfassigmentNode select: [ :anInterval | rangesForAssignNode includesAllOf: anInterval ]) anyOne.
	newReadWithGetterCode := instVarNameTargetClass, ' ', instanceVariableName.
	rangesOfInstVarNameOnNode := rangesOfInstVarNameSourceClass - offsetNodeCodeReplacer.
	rangesToKeywords add: rangesOfInstVarNameOnNode -> newReadWithGetterCode.! !

!CodeForNodeOnMethod methodsFor: 'accessing' stamp: 'mc 12/26/2022 22:15:55'!
execute
	
	| originalCode |
	rangesForAssignNode := (methodNode completeSourceRangesOf: node ifAbsent: []) detectMin: [ :anInterval | anInterval first] .
	offsetNodeCodeReplacer := rangesForAssignNode first -1.
	originalCode := compiledMethod sourceCode.
	newAssignCode := originalCode copyFrom: rangesForAssignNode first to: rangesForAssignNode last.
	node accept: self.
	^newAssignCode copyReplacing: rangesToKeywords.
	! !

!CodeForNodeOnMethod class methodsFor: 'instance creation' stamp: 'mc 11/30/2022 01:50:18'!
for: aNode replace: instVarNameToReplace onMethod: aCompiledMethod accessingThrough: instVarNameToUseAsReceiver 
	^self new initializeFor: aNode replace: instVarNameToReplace onMethod: aCompiledMethod accessingThrough: instVarNameToUseAsReceiver ! !

!InstanceVariableMixedReplacerVisitor methodsFor: 'initialization' stamp: 'mc 1/24/2023 20:20:16'!
initializeReplace: instVarNameToReplace onMethod: aCompiledMethod accessingThrough: instVarNameToUseAsReceiver 
	instanceVariableName := instVarNameToReplace.
	compiledMethod := aCompiledMethod.
	instVarNameTargetClass := instVarNameToUseAsReceiver.
	methodNode := compiledMethod methodNode.
	rangesToKeywords := OrderedCollection new.! !

!InstanceVariableMixedReplacerVisitor methodsFor: 'accessing' stamp: 'mc 12/15/2022 01:01:36'!
execute
	
	methodNode accept: self.
	^rangesToKeywords.! !

!InstanceVariableMixedReplacerVisitor methodsFor: 'visiting' stamp: 'mc 12/27/2022 14:16:21'!
codeForValue: aNode 
	| nodeReplacer |
	nodeReplacer := CodeForNodeOnMethod for: aNode value replace: instanceVariableName onMethod: compiledMethod accessingThrough: instVarNameTargetClass.
	^nodeReplacer execute.
	! !

!InstanceVariableMixedReplacerVisitor methodsFor: 'visiting' stamp: 'mc 12/26/2022 22:41:22'!
visitAssignmentNode: anAssignmentNode 
	"super visitAssignmentNode: anAssignmentNode."
	| completeRangesOfassigmentNode rangesOfassigmentNode  newAssignmentCode newCodeForValue |
	
	anAssignmentNode variable name = instanceVariableName ifFalse: [anAssignmentNode value accept: self. ^self].
	completeRangesOfassigmentNode := methodNode completeSourceRangesOf: anAssignmentNode ifAbsent: [].
	completeRangesOfassigmentNode removeAllSuchThat: [ :aSourceInterval | (rangesToKeywords collect: [ :anAssociation | anAssociation key]) anySatisfy: [ :aSourceIntervalToModify | aSourceIntervalToModify includesAllOf: aSourceInterval ] ].
	rangesOfassigmentNode := completeRangesOfassigmentNode detectMin: [ :anInterval | anInterval first].
	
	newCodeForValue := self codeForValue: anAssignmentNode.
	
	((anAssignmentNode value isMessageNode and: [anAssignmentNode value isKeywordMessageSend]) or: [anAssignmentNode value isAssignmentNode ])
		ifTrue: [ newCodeForValue := '(', newCodeForValue, ')'].
	newAssignmentCode := instVarNameTargetClass, ' ', instanceVariableName, ': ', newCodeForValue.
	rangesToKeywords add: rangesOfassigmentNode -> newAssignmentCode.
	! !

!InstanceVariableMixedReplacerVisitor methodsFor: 'visiting' stamp: 'mc 11/30/2022 19:20:18'!
visitInstanceVariableNode: anInstanceVariableNode 
	| completeRangesOfassigmentNode newReadWithGetterCode rangesOfInstVarNameSourceClass |
	anInstanceVariableNode name = instanceVariableName ifFalse: [^self].
	completeRangesOfassigmentNode := methodNode rangeForNode: anInstanceVariableNode ifAbsent: [].
	"removeAllSuchThat:"
	"completeRangesOfassigmentNode removeAllFoundIn: (rangesToKeywords collect: [ :anAssociation | anAssociation key])."
	completeRangesOfassigmentNode removeAllSuchThat: [ :aSourceInterval | (rangesToKeywords collect: [ :anAssociation | anAssociation key]) anySatisfy: [ :aSourceIntervalToModify | aSourceIntervalToModify includesAllOf: aSourceInterval ] ].
	rangesOfInstVarNameSourceClass := completeRangesOfassigmentNode first.
	newReadWithGetterCode := instVarNameTargetClass, ' ', instanceVariableName.
	rangesToKeywords add: rangesOfInstVarNameSourceClass -> newReadWithGetterCode.! !

!InstanceVariableMixedReplacerVisitor class methodsFor: 'instance creation' stamp: 'mc 11/29/2022 02:37:35'!
replace: instVarNameToReplace onMethod: aCompiledMethod accessingThrough: instVarNameToUseAsReceiver
	^self new initializeReplace: instVarNameToReplace onMethod: aCompiledMethod accessingThrough: instVarNameToUseAsReceiver ! !

!InstanceVariableReaderFinderVisitor methodsFor: 'visiting' stamp: 'mc 11/16/2022 23:05:06'!
visitAssignmentNode: anAssignmentNode
	anAssignmentNode value accept: self! !

!InstanceVariableReaderFinderVisitor methodsFor: 'visiting' stamp: 'mc 11/16/2022 00:58:23'!
visitInstanceVariableNode: anInstanceVariableNode
	result := result or: [anInstanceVariableNode name = instanceVariableName]! !

!InstanceVariableReaderFinderVisitor methodsFor: 'accessing' stamp: 'mc 11/7/2022 02:36:05'!
result
	^result! !

!InstanceVariableReaderFinderVisitor methodsFor: 'initialization' stamp: 'mc 11/16/2022 01:31:17'!
initializeFor: anInstanceVariableName 
	instanceVariableName := anInstanceVariableName.
	result := false.! !

!InstanceVariableReaderFinderVisitor class methodsFor: 'instance creation' stamp: 'mc 11/16/2022 01:32:02'!
newFor: anInstanceVariableName
	^self new initializeFor: anInstanceVariableName ! !

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

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/26/2022 19:02:09'!
test01CanMoveInstVarWhenThereIsNoReferenceToSourceIV

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv1 iv2'.
	targetClass  := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRectoring named: 'iv1' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self deny: (sourceClass instVarNames includes: 'iv1').
	self assert: (targetClass instVarNames includes: 'iv1').
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 1/10/2023 01:16:14'!
test02CanMoveInstVarWhenThereIsAReferenceToSourceIV

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv1 iv2'.
	sourceClass compile: 'iv1 ^iv1' .
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRectoring named: 'iv1' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self assert: 'iv1', String newLineString, String tab, '^iv1' equals: (targetClass compiledMethodAt: #iv1) sourceCode.
	self assert: 'iv1 ^iv2 iv1' equals: (sourceClass compiledMethodAt: #iv1) sourceCode.
	
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 1/10/2023 03:27:46'!
test03CanMoveInstVarWhenThereIsAReferenceToSourceIV

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv5'.
	sourceClass compile: 'iv5 ^iv5'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRectoring named: 'iv5' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self assert: 'iv5', String newLineString, String tab, '^iv5' equals: (targetClass compiledMethodAt: #iv5) sourceCode.
	self assert: 'iv5 ^iv2 iv5' equals: (sourceClass compiledMethodAt: #iv5) sourceCode.
	
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/30/2022 10:08:47'!
test04MoveInstVarWithNoReferencesShouldNotCreateGetterOnTarget

	| refactoring sourceClass targetClass targetMessages |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv1 iv2'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRectoring named: 'iv1' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	targetMessages := targetClass methodDictionary keys .
	self deny: (targetMessages includes: #iv1).
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 1/10/2023 03:27:57'!
test05CanMoveInstVarWhenThereIsAReferenceToSourceIV

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv3 iv5'.
	sourceClass compile: 'iv5 ^iv5'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRectoring named: 'iv5' from: sourceClass to: targetClass accessingThrough: 'iv3'.
	refactoring apply.
	
	self assert: 'iv5', String newLineString, String tab, '^iv5' equals: (targetClass compiledMethodAt: #iv5) sourceCode.
	self assert: 'iv5 ^iv3 iv5' equals: (sourceClass compiledMethodAt: #iv5) sourceCode.
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/30/2022 10:08:32'!
test06MoveInstVarWithNoReaderReferencesShouldNotCreateGetterOnTarget

	| refactoring sourceClass targetClass targetMessages |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv1 iv2'.
	sourceClass compile: 'iv1: anObject iv1 := anObject.'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRectoring named: 'iv1' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	targetMessages := targetClass methodDictionary keys .
	self deny: (targetMessages includes: #iv1).
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 1/10/2023 03:28:04'!
test07CanMoveInstVarWhenThereAreTwoReferencesToSourceIV

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv5'.
	sourceClass compile: 'firstRef ^iv5'.
	sourceClass compile: 'secondRef ^iv5'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRectoring named: 'iv5' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self assert: 'iv5', String newLineString, String tab, '^iv5' equals: (targetClass compiledMethodAt: #iv5) sourceCode.
	self assert: 'firstRef ^iv2 iv5' equals: (sourceClass compiledMethodAt: #firstRef) sourceCode.
	self assert: 'secondRef ^iv2 iv5' equals: (sourceClass compiledMethodAt: #secondRef) sourceCode.
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 1/11/2023 02:16:38'!
test08CanMoveInstVarWhenThereIsAWriteReferencesToSourceIV

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv5'.
	sourceClass compile: 'iv5: anObject iv5 := anObject.'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRectoring named: 'iv5' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self deny: (sourceClass instVarNames includes: 'iv5').
	self assert: (targetClass instVarNames includes: 'iv5').
	self assert: 'iv5: anObject', String newLineString, String tab, '^iv5 := anObject.' equals: (targetClass compiledMethodAt: #iv5:) sourceCode.
	self assert: 'iv5: anObject iv2 iv5: anObject.' equals: (sourceClass compiledMethodAt: #iv5:) sourceCode.
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 1/11/2023 02:16:51'!
test09CanMoveInstVarWhenThereIsAWriteReferencesToSourceIV

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv6'.
	sourceClass compile: 'iv6: anObject iv6 := anObject.'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRectoring named: 'iv6' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self deny: (sourceClass instVarNames includes: 'iv6').
	self assert: (targetClass instVarNames includes: 'iv6').
	self assert: 'iv6: anObject', String newLineString, String tab,'^iv6 := anObject.' equals: (targetClass compiledMethodAt: #iv6:) sourceCode.
	self assert: 'iv6: anObject iv2 iv6: anObject.' equals: (sourceClass compiledMethodAt: #iv6:) sourceCode.
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 1/11/2023 02:17:09'!
test10IdentationShouldNotBeAProblemToMoveInstVar

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv6'.
	sourceClass compile: self codeWithBadIdentation.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRectoring named: 'iv6' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self deny: (sourceClass instVarNames includes: 'iv6').
	self assert: (targetClass instVarNames includes: 'iv6').
	self assert: 'iv6: anObject', String newLineString, String tab,'^iv6 := anObject.' equals: (targetClass compiledMethodAt: #iv6:) sourceCode.
	self assert: self expectedCodeWitBadIdentation equals: (sourceClass compiledMethodAt: #iv6:) sourceCode.
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 1/11/2023 02:17:29'!
test11CanMoveInstVarWhenThereAreTwoAssignationsOnSameMethod

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv6'.
	sourceClass compile: self setterWithTwoAssignations.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRectoring named: 'iv6' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self deny: (sourceClass instVarNames includes: 'iv6').
	self assert: (targetClass instVarNames includes: 'iv6').
	self assert: 'iv6: anObject', String newLineString, String tab, '^iv6 := anObject.' equals: (targetClass compiledMethodAt: #iv6:) sourceCode.
	self assert: self setterWithTwoAssignationsAfterRefactoring equals: (sourceClass compiledMethodAt: #iv6:) sourceCode.! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 1/11/2023 02:17:52'!
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
	
	refactoring := MoveInstanceVariableRectoring named: 'iv6' from: sourceClass to: targetClass accessingThrough: 'iv2'.
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

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/30/2022 10:07:50'!
test13CanMoveInstVarWhenThereAreTwoReadReferencesToSourceIV

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv6'.
	sourceClass compile: 'iv6
|iiiiiiv6|
iiiiiiv6 := 1.
iv6.
^iv6'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRectoring named: 'iv6' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self assert: 'iv6
|iiiiiiv6|
iiiiiiv6 := 1.
iv2 iv6.
^iv2 iv6' equals: (sourceClass compiledMethodAt: #iv6) sourceCode.
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/30/2022 10:07:45'!
test14CanMoveInstVarWhenThereIsAReadReferencesInAssignation

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv6'.
	sourceClass compile: 'readOnAssign
|tmp|
tmp := iv6 byteAt: 2.
^tmp'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRectoring named: 'iv6' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self assert: 'readOnAssign
|tmp|
tmp := iv2 iv6 byteAt: 2.
^tmp' equals: (sourceClass compiledMethodAt: #readOnAssign) sourceCode.
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/30/2022 10:07:40'!
test15CanMoveInstVarWhenThereIsAMixedReferencesToSourceIV

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv1 iv2 iv3'.
	sourceClass compile: 'iv1: anObject
	iv1 := iv3 byteAt: 2.
	iv1 := iv1 + 1.
	iv3 := 1.
	^iv3.'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRectoring named: 'iv1' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self assert: 'iv1: anObject
	iv2 iv1: (iv3 byteAt: 2).
	iv2 iv1: iv2 iv1 + 1.
	iv3 := 1.
	^iv3.' equals: (sourceClass compiledMethodAt: #iv1:) sourceCode.
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/30/2022 10:07:22'!
test16CanMoveInstVarWhenThereIsAMixedReferencesToSourceIV

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv1 iv2 iv3'.
	sourceClass compile: 'iv1: anObject
iv1 := iv1 + 1.
iv3 := 1.
^iv3.'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRectoring named: 'iv1' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self assert: 'iv1: anObject
iv2 iv1: iv2 iv1 + 1.
iv3 := 1.
^iv3.' equals: (sourceClass compiledMethodAt: #iv1:) sourceCode.
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/30/2022 10:07:13'!
test17SubClassReadMethodsShouldBeRefactored

	| refactoring sourceClass targetClass sourceSuperClass |
	sourceSuperClass := self createClassNamed: #SourceSuperClass instanceVariableNames:'iv6 iv2'.
	sourceClass := self createClassNamed: #SourceClass subclassOf: sourceSuperClass.
	sourceClass compile: 'iv6
	^iv6'.
	sourceSuperClass compile: 'iv6
	^iv6.'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRectoring named: 'iv6' from: sourceSuperClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self assert: 'iv6
	^iv2 iv6' equals: (sourceClass compiledMethodAt: #iv6) sourceCode.

	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/30/2022 10:07:07'!
test18SubClassWriteMethodsShouldBeRefactored

	| refactoring sourceClass targetClass sourceSuperClass |
	sourceSuperClass := self createClassNamed: #SourceSuperClass instanceVariableNames:'iv6 iv2'.
	sourceClass := self createClassNamed: #SourceClass subclassOf: sourceSuperClass.
	sourceClass compile: 'iv6: anObject
	iv6 := anObject'.
	sourceSuperClass compile: 'iv6: anObject
	iv6 := anObject.'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRectoring named: 'iv6' from: sourceSuperClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self assert: 'iv6: anObject
	iv2 iv6: anObject' equals: (sourceClass compiledMethodAt: #iv6:) sourceCode.

	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 1/11/2023 02:18:17'!
test19MixedMethodsShouldBeRefactored

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv5'.
	sourceClass compile: 'iv5
iv5 := 1.
^iv5'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRectoring named: 'iv5' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self assert: 'iv5', String newLineString, String tab, '^iv5' equals: (targetClass compiledMethodAt: #iv5) sourceCode.
	self assert: 'iv5: anObject', String newLineString, String tab, '^iv5 := anObject.' equals: (targetClass compiledMethodAt: #iv5:) sourceCode.
	self assert: 'iv5
iv2 iv5: 1.
^iv2 iv5' equals: (sourceClass compiledMethodAt: #iv5) sourceCode.
! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 1/11/2023 02:26:42'!
test20MixedMethodsShouldBeRefactored

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv5'.
	sourceClass compile: 'iv5
| tmp1 |
tmp1 := 1.
iv5 := 1.
^iv5'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRectoring named: 'iv5' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self assert: 'iv5', String newLineString, String tab, '^iv5' equals: (targetClass compiledMethodAt: #iv5) sourceCode.
	self assert: 'iv5: anObject', String newLineString, String tab, '^iv5 := anObject.' equals: (targetClass compiledMethodAt: #iv5:) sourceCode.
	self assert: 'iv5
| tmp1 |
tmp1 := 1.
iv2 iv5: 1.
^iv2 iv5' equals: (sourceClass compiledMethodAt: #iv5) sourceCode.
! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 1/11/2023 02:26:55'!
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
	
	refactoring := MoveInstanceVariableRectoring named: 'iv5' from: sourceSuperClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self assert: 'iv5', String newLineString, String tab, '^iv5' equals: (targetClass compiledMethodAt: #iv5) sourceCode.
	self assert: 'iv5: anObject', String newLineString, String tab, '^iv5 := anObject.' equals: (targetClass compiledMethodAt: #iv5:) sourceCode.
	self assert: 'iv5
| tmp1 |
tmp1 := 1.
iv2 iv5: 1.
^iv2 iv5' equals: (sourceClass compiledMethodAt: #iv5) sourceCode.
! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/30/2022 10:06:36'!
test22WriteMethodsWithSameBlockCodeShouldBeRefactored

	| refactoring sourceClass targetClass |
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames:'iv6 iv2 iv1'.
	sourceClass compile: 'iv6: anObject
iv6 := anObject'.
	sourceClass compile: 'iv66: anObject
iv6 := anObject.'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRectoring named: 'iv6' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self assert: 'iv6: anObject
iv2 iv6: anObject' equals: (sourceClass compiledMethodAt: #iv6:) sourceCode.
	self assert: 'iv66: anObject
iv2 iv6: anObject.' equals: (sourceClass compiledMethodAt: #iv66:) sourceCode.
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/30/2022 10:06:29'!
test23MoveInstVarWithNoReadReferencesOnIVShouldNotCreateGetterOnTarget

	| refactoring sourceClass targetClass targetMessages |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv1 iv2 iv3'.
	targetClass := self createClassNamed: #TargetClass.
	sourceClass compile: 'iv1: anObject
iv1 := anObject.
iv3 := 1.
^iv3.'.
	
	refactoring := MoveInstanceVariableRectoring named: 'iv1' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	targetMessages := targetClass methodDictionary keys .
	self deny: (targetMessages includes: #iv1).
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 1/11/2023 02:27:08'!
test24CanMoveInstVarWhenThereIsAWriteReferencesAndKeywordMessage

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv1 iv2 iv3'.
	sourceClass compile:  
'iv1: anObject
	iv1 := iv3 byteAt: 2.
	iv3 := 1.
	^iv3.'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRectoring named: 'iv1' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self assert: 'iv1: anObject', String newLineString, String tab, '^iv1 := anObject.' equals: (targetClass compiledMethodAt: #iv1:) sourceCode.
	self assert: 
'iv1: anObject
	iv2 iv1: (iv3 byteAt: 2).
	iv3 := 1.
	^iv3.' equals: (sourceClass compiledMethodAt: #iv1:) sourceCode.
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/30/2022 10:06:16'!
test25ThereAreOnly2VersionsAfterRefactoringMethodWithTwoWriteReferences

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv6'.
	sourceClass compile: self setterWithTwoAssignations.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRectoring named: 'iv6' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self assert: 2 equals: (VersionsBrowser versionCountForSelector: #iv6: class: sourceClass).! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/30/2022 10:06:02'!
test26ThereAreOnly2VersionsAfterRefactoringMethodWithTwoReadReferences

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv6'.
	sourceClass compile: 'iv6
|iiiiiiv6|
iiiiiiv6 := 1.
iv6.
^iv6'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRectoring named: 'iv6' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.

	self assert: 2 equals: (VersionsBrowser versionCountForSelector: #iv6 class: sourceClass).
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/30/2022 10:05:54'!
test27ThereAreOnly2VersionsAfterRefactoringMethodWithMixedReferences

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv6'.
	sourceClass compile: 'iv6
| tmp1 |
tmp1 := 1.
iv6 := 1.
^iv6'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRectoring named: 'iv6' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.

	self assert: 2 equals: (VersionsBrowser versionCountForSelector: #iv6 class: sourceClass).
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/30/2022 10:05:48'!
test28ParenthesisShouldBeUsedOnDoubleAssignation

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv6'.
	sourceClass compile: 'iv6
| tmp1 |
iv6 := tmp1 := 1.'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRectoring named: 'iv6' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.

	self assert: 'iv6
| tmp1 |
iv2 iv6: (tmp1 := 1).' equals: (sourceClass compiledMethodAt: #iv6) sourceCode.
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/30/2022 10:05:40'!
test29ParenthesisShouldBeUsedOnDoubleAssignation

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv6'.
	sourceClass compile: 'iv6
| tmp1 |
iv6 := iv6 := 1.'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRectoring named: 'iv6' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.

	self assert: 'iv6
| tmp1 |
iv2 iv6: (iv2 iv6: 1).' equals: (sourceClass compiledMethodAt: #iv6) sourceCode.
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/30/2022 10:05:35'!
test30ParenthesisShouldBeUsedOnDoubleAssignation

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv6'.
	sourceClass compile: 'iv6
	| tmp1 |
	tmp := 1.
	iv6 := iv6 := iv6 byteAt: tmp.
	tmp := iv6 := iv6 byteAt: tmp.
	^tmp.'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRectoring named: 'iv6' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.

	self assert: 'iv6
	| tmp1 |
	tmp := 1.
	iv2 iv6: (iv2 iv6: (iv2 iv6 byteAt: tmp)).
	tmp := iv2 iv6: (iv2 iv6 byteAt: tmp).
	^tmp.' equals: (sourceClass compiledMethodAt: #iv6) sourceCode.
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/30/2022 10:05:26'!
test31_validation_getterMessageShouldntExistsOnTarget

	| sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv1 iv2'.
	sourceClass compile: 'methodReadsIv1
^iv1'.
	targetClass := self createClassNamed: #TargetClass.
	targetClass compile: 'iv1
^5'.
	
	self 
		should: [MoveInstanceVariableRectoring named: 'iv1' from: sourceClass to: targetClass accessingThrough: 'iv2']
		raise: RefactoringError
		withExceptionDo: [ :error |
			self assert: MoveInstanceVariableRectoring getterExistsOnTargetClassErrorMessage equals: error messageText ].
	

	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/30/2022 10:05:18'!
test32_validation_getterMessageShouldntExistsOnTarget

	| sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv3'.
	sourceClass compile: 'methodReadsIv1
^iv2'.
	targetClass := self createClassNamed: #TargetClass.
	targetClass compile: 'iv2
^5'.
	
	self 
		should: [MoveInstanceVariableRectoring named: 'iv2' from: sourceClass to: targetClass accessingThrough: 'iv3']
		raise: RefactoringError
		withExceptionDo: [ :error |
			self assert: MoveInstanceVariableRectoring getterExistsOnTargetClassErrorMessage equals: error messageText ].
	

	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/30/2022 10:05:13'!
test33_validation_getterMessageShouldntExistsOnTargetSuperclass

	| sourceClass targetClass targetSuperClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv3'.
	sourceClass compile: 'methodReadsIv1
^iv2'.
	targetSuperClass := self createClassNamed: #TargetSuperClass .
	targetSuperClass compile: 'iv2
^5'.	
	targetClass := self createClassNamed: #TargetClass subclassOf: targetSuperClass.

	self 
		should: [MoveInstanceVariableRectoring named: 'iv2' from: sourceClass to: targetClass accessingThrough: 'iv3']
		raise: RefactoringError
		withExceptionDo: [ :error |
			self assert: MoveInstanceVariableRectoring getterExistsOnTargetClassErrorMessage equals: error messageText ].
	

	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/30/2022 10:05:02'!
test34_validation_instanceVariableShouldntExistsOnTarget

	| sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv3'.
	targetClass := self createClassNamed: #TargetClass instanceVariableNames: 'iv2'.
	
	self 
		should: [MoveInstanceVariableRectoring named: 'iv2' from: sourceClass to: targetClass accessingThrough: 'iv3']
		raise: RefactoringError
		withExceptionDo: [ :error |
			self assert: MoveInstanceVariableRectoring instanceVariableExistsOnTargetHierarchyErrorMessage equals: error messageText ].
	

	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/30/2022 10:04:52'!
test35_validation_instanceVariableShouldntExistsOnTargetSubclass

	| sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv3'.
	targetClass := self createClassNamed: #TargetClass.
	self createClassNamed: #TargetSubClass subclassOf: targetClass instanceVariableNames: 'iv2'.
	
	self 
		should: [MoveInstanceVariableRectoring named: 'iv2' from: sourceClass to: targetClass accessingThrough: 'iv3']
		raise: RefactoringError
		withExceptionDo: [ :error |
			self assert: MoveInstanceVariableRectoring instanceVariableExistsOnTargetHierarchyErrorMessage equals: error messageText ].
	

	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/30/2022 10:04:45'!
test36_validation_setterMessageShouldntExistsOnTarget

	| sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv1 iv2'.
	sourceClass compile: 'methodWritesIv1
^iv1 := 1'.
	targetClass := self createClassNamed: #TargetClass.
	targetClass compile: 'iv1: anObject
^anObject + 5'.
	
	self 
		should: [MoveInstanceVariableRectoring named: 'iv1' from: sourceClass to: targetClass accessingThrough: 'iv2']
		raise: RefactoringError
		withExceptionDo: [ :error |
			self assert: MoveInstanceVariableRectoring setterExistsOnTargetClassErrorMessage equals: error messageText ].
	

	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/30/2022 10:04:39'!
test37_validation_instanceVariableToMoveShouldExistsOnSource

	| sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2'.
	targetClass := self createClassNamed: #TargetClass.
	
	self 
		should: [MoveInstanceVariableRectoring named: 'iv1' from: sourceClass to: targetClass accessingThrough: 'iv2']
		raise: RefactoringError
		withExceptionDo: [ :error |
			self assert: MoveInstanceVariableRectoring instanceVariableToMoveShouldExistOnSourceClassErrorMessage equals: error messageText ].
	

	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/30/2022 10:04:32'!
test38_validation_instanceVariableToAccessThroughShouldExistsOnSource

	| sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv1'.
	targetClass := self createClassNamed: #TargetClass.
	
	self 
		should: [MoveInstanceVariableRectoring named: 'iv1' from: sourceClass to: targetClass accessingThrough: 'iv2']
		raise: RefactoringError
		withExceptionDo: [ :error |
			self assert: MoveInstanceVariableRectoring instanceVariableToAccessThroughShouldExistOnSourceClassErrorMessage equals: error messageText ].
	

	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 1/12/2023 23:09:39'!
test39_validation_souceclassAndTargetClassCanNotBeTheSame

	| sourceClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv3'.
	
	self 
		should: [MoveInstanceVariableRectoring named: 'iv2' from: sourceClass to: sourceClass accessingThrough: 'iv3']
		raise: RefactoringError
		withExceptionDo: [ :error |
			self assert: MoveInstanceVariableRectoring souceClassAndTargetClassCanNotBeTheSameErrorMessage equals: error messageText ].
	

	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 1/12/2023 23:17:19'!
test40_validation_targetClassCanNotBeSuperClassOfSourceClass

	| sourceClass targetClass |
	
	targetClass := self createClassNamed: #TargetSubClass.
	sourceClass := self createClassNamed: #SourceClass subclassOf: targetClass instanceVariableNames: 'iv2 iv3'.
	
	
	self 
		should: [MoveInstanceVariableRectoring named: 'iv2' from: sourceClass to: targetClass accessingThrough: 'iv3']
		raise: RefactoringError
		withExceptionDo: [ :error |
			self assert: MoveInstanceVariableRectoring targetClassCanNotBeSuperClassOfSourceClassErrorMessage equals: error messageText ].
	

	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 1/12/2023 23:28:50'!
test41_validation_targetClassCanNotBeSubClassOfSourceClass

	| sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass  instanceVariableNames: 'iv2 iv3'.
	targetClass := self createClassNamed: #TargetSubClass subclassOf: sourceClass.
	
	self 
		should: [MoveInstanceVariableRectoring named: 'iv2' from: sourceClass to: targetClass accessingThrough: 'iv3']
		raise: RefactoringError
		withExceptionDo: [ :error |
			self assert: MoveInstanceVariableRectoring targetClassCanNotBeSubClassOfSourceClassErrorMessage equals: error messageText ].
	

	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 1/21/2023 11:14:45'!
test42_instanceVariableToAccessThroughShouldExistsOnSourceHierarchy

	| sourceClass targetClass sourceSuperClass refactoring |
	
	sourceSuperClass := self createClassNamed: #SourceSuperClass instanceVariableNames: 'iv2'.
	sourceClass := self createClassNamed: #SourceClass subclassOf: sourceSuperClass instanceVariableNames: 'iv1'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRectoring named: 'iv1' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self deny: (sourceClass instVarNames includes: 'iv1').
	self assert: (targetClass instVarNames includes: 'iv1').
	! !

!MoveInstanceVariableApplier methodsFor: 'initialization' stamp: 'mc 1/22/2023 14:34:12'!
askTargetClassName
	| targetClassNameTmp |
	targetClassNameTmp := ClassNameRequestMorph request: 'Enter target class name:' initialAnswer: '' orCancel: requestExitBlock.
	targetClassNameTmp := targetClassNameTmp withoutSeparators.
	targetClass := (Smalltalk at: targetClassNameTmp asSymbol)	! !

!MoveInstanceVariableApplier methodsFor: 'initialization' stamp: 'mc 1/6/2023 00:10:07'!
createRefactoring
	^MoveInstanceVariableRectoring 
		named: instanceVariableName 
		from: classToRefactor 
		to: targetClass
		accessingThrough: accessingThroughinstanceVariableName.! !

!MoveInstanceVariableApplier methodsFor: 'initialization' stamp: 'mc 1/5/2023 18:23:52'!
selectVariableLabel
	^'Select variable to access through'! !

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

!MoveInstanceVariableApplier methodsFor: 'refactoring - parameters request' stamp: 'mc 2/7/2023 23:44:01'!
requestRefactoringParameters

	self 
		chooseInstanceVariableToMove;
		selectClassWichInstaceVariableIsDefined;
		chooseInstanceVariableToAccessThrough;
		askTargetClassName! !

!MoveInstanceVariableApplier methodsFor: 'refactoring - parameters request' stamp: 'mc 2/8/2023 01:28:49'!
selectClassWichInstaceVariableIsDefined
	| classToRefactorWithIVDefined |
	"whichClassDefinesInstanceVariable: 'iv2' ifNone: []"
	"self halt."
	classToRefactorWithIVDefined := classToRefactor whichClassDefinesInstanceVariable: instanceVariableName ifNone: [Refactoring refactoringErrorClass signal: 'Instance variable ', instanceVariableName, ' does not exist in ', targetClass name, ' herarchy'].
	classToRefactorWithIVDefined = classToRefactor ifFalse: [ 
		Refactoring refactoringWarning: 'Instance variable is not defined on class ', classToRefactor name.
		classToRefactor := classToRefactorWithIVDefined ]! !

!MoveInstanceVariableApplier methodsFor: 'refactoring - parameters request' stamp: 'mc 1/22/2023 02:08:37'!
selectVariableToMoveLabel
	^'Choose instance variable to move'! !

!MoveInstanceVariableRectoring methodsFor: 'initialization' stamp: 'mc 10/6/2022 01:06:32'!
initializeNamed: anInstVarNameSourceClass from: aSourceClass to: aTargetClass in: anInstVarNameTargetClass 
	instVarNameSourceClass := anInstVarNameSourceClass.
	sourceClass := aSourceClass.
	targetClass := aTargetClass.
	instVarNameTargetClass := anInstVarNameTargetClass.! !

!MoveInstanceVariableRectoring methodsFor: 'applying' stamp: 'mc 11/6/2022 00:32:15'!
apply
	targetClass addInstVarName: instVarNameSourceClass.
	self replaceReadAccess.
	self replaceWriteAccess.
	self replaceMixedAccess.
	sourceClass removeInstVarName: instVarNameSourceClass.! !

!MoveInstanceVariableRectoring methodsFor: 'private-writing' stamp: 'mc 10/12/2022 00:28:04'!
replaceWriteAccess
^ self writeAccessInSourceClass 
	ifNotEmpty: [
		self createSetterOnTargetClass.
		self replaceWriteReferencesWithSettersOnSourceClass.
		]
	! !

!MoveInstanceVariableRectoring methodsFor: 'private-writing' stamp: 'mc 12/15/2022 01:01:59'!
replaceWriteReferencesOnSourceClassFor: aWriteMethod
	| replacer newSource rangesToKeywords |
	replacer := InstanceVariableMixedReplacerVisitor 
				replace: instVarNameSourceClass 
				onMethod: aWriteMethod 
				accessingThrough: instVarNameTargetClass.
	rangesToKeywords := replacer execute.
	newSource := aWriteMethod sourceCode copyReplacing: rangesToKeywords.
	aWriteMethod methodClass compile: newSource.! !

!MoveInstanceVariableRectoring methodsFor: 'private-writing' stamp: 'mc 11/29/2022 02:02:55'!
replaceWriteReferencesWithSettersOnSourceClass
	self writeAccessInSourceClass do: [  :aWriteMethod |  
		self replaceWriteReferencesOnSourceClassFor: aWriteMethod.
		]! !

!MoveInstanceVariableRectoring methodsFor: 'private-writing' stamp: 'mc 11/28/2022 02:10:39'!
writeAccessInSourceClass
	| writeMethods accessMethods |
	writeMethods := OrderedCollection new.
	sourceClass withAllSubclassesDo: [ :aSubClass | | selectorsWritingIV | 
		selectorsWritingIV := (aSubClass whichSelectorsStoreInto: instVarNameSourceClass) asOrderedCollection.
		writeMethods addAll: ( selectorsWritingIV collect: [ :aSelector | aSubClass methodDict at: aSelector ])
		].
	accessMethods := OrderedCollection new.
	sourceClass withAllSubclassesDo: [ :aSubClass | | selectorsAccessingIV methodsAccessingIV methodsWhichReadsIV | 
		selectorsAccessingIV := (aSubClass whichSelectorsAccess: instVarNameSourceClass) asOrderedCollection .
		methodsAccessingIV := selectorsAccessingIV collect: [ :aSelector | aSubClass methodDict at: aSelector ].
		methodsWhichReadsIV := methodsAccessingIV select: [ :aMethod | self isReadingInstanceVariable: aMethod ].
		accessMethods addAll: methodsWhichReadsIV.
		].
	writeMethods removeAllFoundIn: accessMethods.
	^writeMethods! !

!MoveInstanceVariableRectoring methodsFor: 'private-createMethods' stamp: 'mc 1/10/2023 01:14:12'!
createGetterOnTargetClass

	^ targetClass compile: instVarNameSourceClass, String newLineString, String tab, '^', instVarNameSourceClass! !

!MoveInstanceVariableRectoring methodsFor: 'private-createMethods' stamp: 'mc 1/11/2023 02:12:59'!
createSetterOnTargetClass
	^ targetClass compile: instVarNameSourceClass, ': anObject', 
	String newLineString, String tab, '^', instVarNameSourceClass, ' := anObject.'! !

!MoveInstanceVariableRectoring methodsFor: 'private-mixed' stamp: 'mc 11/10/2022 23:44:51'!
mixedAccessInSourceClass
	| mixedMethods |
	mixedMethods := OrderedCollection new.
	sourceClass withAllSubclassesDo: [ :aSubClass | | selectorsAccessingIV methodsAccessingIV methodsReadingAndWritingIV | 
		selectorsAccessingIV := (aSubClass whichSelectorsStoreInto: instVarNameSourceClass) asOrderedCollection.
		methodsAccessingIV := selectorsAccessingIV collect: [ :aSelector | aSubClass methodDict at: aSelector ].
		methodsReadingAndWritingIV := methodsAccessingIV select: [ :aMethod | self isReadingInstanceVariable: aMethod].
		mixedMethods addAll: methodsReadingAndWritingIV.
		].
	^ mixedMethods! !

!MoveInstanceVariableRectoring methodsFor: 'private-mixed' stamp: 'mc 11/7/2022 23:43:06'!
replaceMixedAccess
	self mixedAccessInSourceClass 
		ifNotEmpty: [
			self createGetterOnTargetClass.
			self createSetterOnTargetClass.
			self replaceMixedAccessInSourceClass.
		].
! !

!MoveInstanceVariableRectoring methodsFor: 'private-mixed' stamp: 'mc 12/15/2022 01:00:21'!
replaceMixedAccessInSourceClass
	| newSource rangesToKeywords |
	self mixedAccessInSourceClass do: [ :aMethod | | replacer |
		replacer := InstanceVariableMixedReplacerVisitor 
			replace: instVarNameSourceClass 
			onMethod: aMethod 
			accessingThrough: instVarNameTargetClass.
		rangesToKeywords := replacer execute.
		newSource := aMethod sourceCode copyReplacing: rangesToKeywords.
		aMethod methodClass compile: newSource.
		]! !

!MoveInstanceVariableRectoring methodsFor: 'private-reading' stamp: 'mc 11/16/2022 01:27:41'!
isReadingInstanceVariable: aMethod 
	| visitor |
	visitor := InstanceVariableReaderFinderVisitor newFor: instVarNameSourceClass.
	aMethod methodNode accept: visitor.
	^visitor result.! !

!MoveInstanceVariableRectoring methodsFor: 'private-reading' stamp: 'mc 11/11/2022 01:03:14'!
readAccessInSourceClass
	| writeMethods accessMethods |
	writeMethods := OrderedCollection new.
	sourceClass withAllSubclassesDo: [ :aSubClass | | selectorsWritingIV | 
		selectorsWritingIV := (aSubClass whichSelectorsStoreInto: instVarNameSourceClass) asOrderedCollection.
		writeMethods addAll: ( selectorsWritingIV collect: [ :aSelector | aSubClass methodDict at: aSelector ])
		].
	accessMethods := OrderedCollection new.
	sourceClass withAllSubclassesDo: [ :aSubClass | | selectorsAccessingIV | 
		selectorsAccessingIV := (aSubClass whichSelectorsAccess: instVarNameSourceClass) asOrderedCollection .
		accessMethods addAll: ( selectorsAccessingIV collect: [ :aSelector | aSubClass methodDict at: aSelector ])
		].
	accessMethods removeAll: writeMethods.
	^ accessMethods! !

!MoveInstanceVariableRectoring methodsFor: 'private-reading' stamp: 'mc 10/11/2022 02:29:21'!
replaceReadAccess

^ self readAccessInSourceClass 
	ifNotEmpty: [
		self createGetterOnTargetClass.
		self replaceReadReferencesWithGettersOnSourceClass.
		]! !

!MoveInstanceVariableRectoring methodsFor: 'private-reading' stamp: 'mc 1/25/2023 20:15:38'!
replaceReadReferencesWithGettersOnSourceClass

	self readAccessInSourceClass do: [ :aCompiledMetthod | 
			| replacer newSource rangesToKeywords |
			replacer := InstanceVariableMixedReplacerVisitor 
				replace: instVarNameSourceClass 
				onMethod: aCompiledMetthod 
				accessingThrough: instVarNameTargetClass.
			rangesToKeywords := replacer execute.
			newSource := aCompiledMetthod sourceCode copyReplacing: rangesToKeywords.
			aCompiledMetthod methodClass compile: newSource.
			].! !

!MoveInstanceVariableRectoring class methodsFor: 'error messages' stamp: 'mc 12/21/2022 02:26:20'!
getterExistsOnTargetClassErrorMessage

	^ 'getter exists on target class'! !

!MoveInstanceVariableRectoring class methodsFor: 'error messages' stamp: 'mc 12/22/2022 19:24:26'!
instanceVariableExistsOnTargetHierarchyErrorMessage

	^ 'instance variable exists on target hierarchy'! !

!MoveInstanceVariableRectoring class methodsFor: 'error messages' stamp: 'mc 12/22/2022 22:24:11'!
instanceVariableToAccessThroughShouldExistOnSourceClassErrorMessage
	^'instance variable to access through does not exists on source class'.! !

!MoveInstanceVariableRectoring class methodsFor: 'error messages' stamp: 'mc 12/22/2022 22:19:08'!
instanceVariableToMoveShouldExistOnSourceClassErrorMessage
	^'instance variable does not exists on source class'.! !

!MoveInstanceVariableRectoring class methodsFor: 'error messages' stamp: 'mc 12/22/2022 19:21:15'!
setterExistsOnTargetClassErrorMessage
	^'setter exists on target class'! !

!MoveInstanceVariableRectoring class methodsFor: 'error messages' stamp: 'mc 1/12/2023 23:09:23'!
souceClassAndTargetClassCanNotBeTheSameErrorMessage
	^'source class and target class can not be the same'.! !

!MoveInstanceVariableRectoring class methodsFor: 'error messages' stamp: 'mc 1/12/2023 23:29:42'!
targetClassCanNotBeSubClassOfSourceClassErrorMessage
	^'Target class can not be sub class of source class. Use push-down refactoring'! !

!MoveInstanceVariableRectoring class methodsFor: 'error messages' stamp: 'mc 1/12/2023 23:25:12'!
targetClassCanNotBeSuperClassOfSourceClassErrorMessage
	^'Target class can not be super class of source class. Use push-up refactoring'! !

!MoveInstanceVariableRectoring class methodsFor: 'instance creation' stamp: 'mc 1/21/2023 11:13:28'!
named: instVarNameSourceClass from: sourceClass to: targetClass accessingThrough: instVarNameTargetClass 
	(sourceClass = targetClass) ifTrue: [ RefactoringError signal: self souceClassAndTargetClassCanNotBeTheSameErrorMessage ].
	(targetClass allSubclasses includes: sourceClass) ifTrue: [ RefactoringError signal: self targetClassCanNotBeSuperClassOfSourceClassErrorMessage ].
	(sourceClass allSubclasses includes: targetClass) ifTrue: [ RefactoringError signal: self targetClassCanNotBeSubClassOfSourceClassErrorMessage ].
	(targetClass allSelectors includes: instVarNameSourceClass asSymbol) ifTrue: [ RefactoringError signal: self getterExistsOnTargetClassErrorMessage ].
	(targetClass allInstVarNamesEverywhere includes: instVarNameSourceClass) ifTrue: [ RefactoringError signal: self instanceVariableExistsOnTargetHierarchyErrorMessage ].
	(targetClass allSelectors includes: (instVarNameSourceClass,':') asSymbol) ifTrue: [ RefactoringError signal: self setterExistsOnTargetClassErrorMessage ].
	(sourceClass instVarNames includes: instVarNameSourceClass) ifFalse: [ RefactoringError signal: self instanceVariableToMoveShouldExistOnSourceClassErrorMessage ].
	(sourceClass allInstVarNames includes: instVarNameTargetClass) ifFalse: [ RefactoringError signal: self instanceVariableToAccessThroughShouldExistOnSourceClassErrorMessage ].
	^self new initializeNamed: instVarNameSourceClass from: sourceClass to: targetClass in: instVarNameTargetClass .! !

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

!TesisRefactoringMenu class methodsFor: 'as yet unclassified' stamp: 'mc 2/7/2023 01:22:07'!
smalltalkEditorCmdShortcutsSpec
	"
	SmalltalkEditor initializeCmdShortcuts
	"
	^#(
		#($4	#contextualMoveInstanceVariable:						'Move instance variable what is under cursor')
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

!SmalltalkEditor methodsFor: '*MoveInstanceVariableRefactoring' stamp: 'mc 1/22/2023 14:57:39'!
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

!SmalltalkEditor methodsFor: '*MoveInstanceVariableRefactoring' stamp: 'mc 2/7/2023 23:57:11'!
moveInstanceVariableOn: aBrowser for: anInstanceVariableName at: aClassToRefactor
	"self halt."
	(MoveInstanceVariableApplier on: aBrowser for: anInstanceVariableName at: aClassToRefactor) value! !

!BrowserWindow methodsFor: '*MoveInstanceVariableRefactoring' stamp: 'mc 2/3/2023 00:08:23'!
contextualMoveInstanceVariable
"self halt."
	model selectedClassOrMetaClass ifNotNil: [ :aClass |
		(MoveInstanceVariableApplier on: model at: aClass ) value].! !
