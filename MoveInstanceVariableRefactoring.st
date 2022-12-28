!classDefinition: #CodeForNodeOnMethod category: 'MoveInstanceVariableRefactoring'!
ParseNodeVisitor subclass: #CodeForNodeOnMethod
	instanceVariableNames: 'instanceVariableName compiledMethod rangesToKeywords methodNode instVarNameTargetClass node rangesForAssignNode newAssignCode offsetNodeCodeReplacer'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'MoveInstanceVariableRefactoring'!

!CodeForNodeOnMethod methodsFor: 'initialization' stamp: 'mc 11/30/2022 01:51:55'!
initializeFor: aNode replace: instVarNameToReplace onMethod: aCompiledMethod accessingThrough: instVarNameToUseAsReceiver 
	node := aNode.
	instanceVariableName := instVarNameToReplace.
	compiledMethod := aCompiledMethod.
	instVarNameTargetClass := instVarNameToUseAsReceiver.
	methodNode := compiledMethod methodNode.
	rangesToKeywords := SortedCollection sortBlock: [ :left :right | left key first < right key first ].! !


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

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'CodeForNodeOnMethod class' category: 'MoveInstanceVariableRefactoring'!
CodeForNodeOnMethod class
	instanceVariableNames: ''!

!CodeForNodeOnMethod class methodsFor: 'instance creation' stamp: 'mc 11/30/2022 01:50:18'!
for: aNode replace: instVarNameToReplace onMethod: aCompiledMethod accessingThrough: instVarNameToUseAsReceiver 
	^self new initializeFor: aNode replace: instVarNameToReplace onMethod: aCompiledMethod accessingThrough: instVarNameToUseAsReceiver ! !


!classDefinition: #InstanceVariableMixedReplacerVisitor category: 'MoveInstanceVariableRefactoring'!
ParseNodeVisitor subclass: #InstanceVariableMixedReplacerVisitor
	instanceVariableNames: 'instanceVariableName compiledMethod rangesToKeywords methodNode instVarNameTargetClass'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'MoveInstanceVariableRefactoring'!

!InstanceVariableMixedReplacerVisitor methodsFor: 'initialization' stamp: 'mc 11/29/2022 02:39:00'!
initializeReplace: instVarNameToReplace onMethod: aCompiledMethod accessingThrough: instVarNameToUseAsReceiver 
	instanceVariableName := instVarNameToReplace.
	compiledMethod := aCompiledMethod.
	instVarNameTargetClass := instVarNameToUseAsReceiver.
	methodNode := compiledMethod methodNode.
	rangesToKeywords := SortedCollection sortBlock: [ :left :right | left key first < right key first ].! !


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

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'InstanceVariableMixedReplacerVisitor class' category: 'MoveInstanceVariableRefactoring'!
InstanceVariableMixedReplacerVisitor class
	instanceVariableNames: ''!

!InstanceVariableMixedReplacerVisitor class methodsFor: 'instance creation' stamp: 'mc 11/29/2022 02:37:35'!
replace: instVarNameToReplace onMethod: aCompiledMethod accessingThrough: instVarNameToUseAsReceiver
	^self new initializeReplace: instVarNameToReplace onMethod: aCompiledMethod accessingThrough: instVarNameToUseAsReceiver ! !


!classDefinition: #InstanceVariableReaderFinderVisitor category: 'MoveInstanceVariableRefactoring'!
ParseNodeVisitor subclass: #InstanceVariableReaderFinderVisitor
	instanceVariableNames: 'result instanceVariableName'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'MoveInstanceVariableRefactoring'!

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

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'InstanceVariableReaderFinderVisitor class' category: 'MoveInstanceVariableRefactoring'!
InstanceVariableReaderFinderVisitor class
	instanceVariableNames: ''!

!InstanceVariableReaderFinderVisitor class methodsFor: 'instance creation' stamp: 'mc 11/16/2022 01:32:02'!
newFor: anInstanceVariableName
	^self new initializeFor: anInstanceVariableName ! !


!classDefinition: #MoveInstanceVariableTest category: 'MoveInstanceVariableRefactoring'!
RefactoringTest subclass: #MoveInstanceVariableTest
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'MoveInstanceVariableRefactoring'!

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

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/26/2022 19:02:40'!
test02CanMoveInstVarWhenThereIsAReferenceToSourceIV

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv1 iv2'.
	sourceClass compile: 'iv1 ^iv1' .
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRectoring named: 'iv1' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self assert: 'iv1 ^iv1' equals: (targetClass compiledMethodAt: #iv1) sourceCode.
	self assert: 'iv1 ^iv2 iv1' equals: (sourceClass compiledMethodAt: #iv1) sourceCode.
	
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/26/2022 19:03:10'!
test03CanMoveInstVarWhenThereIsAReferenceToSourceIV

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv5'.
	sourceClass compile: 'iv5 ^iv5'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRectoring named: 'iv5' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self assert: 'iv5 ^iv5' equals: (targetClass compiledMethodAt: #iv5) sourceCode.
	self assert: 'iv5 ^iv2 iv5' equals: (sourceClass compiledMethodAt: #iv5) sourceCode.
	
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 11/26/2022 01:28:39'!
test03MoveInstVarWithNoReferencesShouldNotCreateGetterOnTarget

	| refactoring sourceClass targetClass targetMessages |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv1 iv2'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRectoring named: 'iv1' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	targetMessages := targetClass methodDictionary keys .
	self deny: (targetMessages includes: #iv1).
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/26/2022 19:04:31'!
test03_01CanMoveInstVarWhenThereIsAReferenceToSourceIV

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv3 iv5'.
	sourceClass compile: 'iv5 ^iv5'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRectoring named: 'iv5' from: sourceClass to: targetClass accessingThrough: 'iv3'.
	refactoring apply.
	
	self assert: 'iv5 ^iv5' equals: (targetClass compiledMethodAt: #iv5) sourceCode.
	self assert: 'iv5 ^iv3 iv5' equals: (sourceClass compiledMethodAt: #iv5) sourceCode.
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 11/26/2022 01:28:40'!
test03_1MoveInstVarWithNoReaderReferencesShouldNotCreateGetterOnTarget

	| refactoring sourceClass targetClass targetMessages |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv1 iv2'.
	sourceClass compile: 'iv1: anObject iv1 := anObject.'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRectoring named: 'iv1' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	targetMessages := targetClass methodDictionary keys .
	self deny: (targetMessages includes: #iv1).
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/26/2022 19:05:38'!
test04CanMoveInstVarWhenThereAreTwoReferencesToSourceIV

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv5'.
	sourceClass compile: 'firstRef ^iv5'.
	sourceClass compile: 'secondRef ^iv5'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRectoring named: 'iv5' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self assert: 'iv5 ^iv5' equals: (targetClass compiledMethodAt: #iv5) sourceCode.
	self assert: 'firstRef ^iv2 iv5' equals: (sourceClass compiledMethodAt: #firstRef) sourceCode.
	self assert: 'secondRef ^iv2 iv5' equals: (sourceClass compiledMethodAt: #secondRef) sourceCode.
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/26/2022 19:06:11'!
test05CanMoveInstVarWhenThereIsAWriteReferencesToSourceIV

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv5'.
	sourceClass compile: 'iv5: anObject iv5 := anObject.'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRectoring named: 'iv5' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self deny: (sourceClass instVarNames includes: 'iv5').
	self assert: (targetClass instVarNames includes: 'iv5').
	self assert: 'iv5: anObject iv5 := anObject. ^anObject' equals: (targetClass compiledMethodAt: #iv5:) sourceCode.
	self assert: 'iv5: anObject iv2 iv5: anObject.' equals: (sourceClass compiledMethodAt: #iv5:) sourceCode.
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/26/2022 19:06:27'!
test06CanMoveInstVarWhenThereIsAWriteReferencesToSourceIV

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv6'.
	sourceClass compile: 'iv6: anObject iv6 := anObject.'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRectoring named: 'iv6' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self deny: (sourceClass instVarNames includes: 'iv6').
	self assert: (targetClass instVarNames includes: 'iv6').
	self assert: 'iv6: anObject iv6 := anObject. ^anObject' equals: (targetClass compiledMethodAt: #iv6:) sourceCode.
	self assert: 'iv6: anObject iv2 iv6: anObject.' equals: (sourceClass compiledMethodAt: #iv6:) sourceCode.
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/26/2022 19:08:10'!
test07IdentationShouldNotBeAProblemToMoveInstVar

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv6'.
	sourceClass compile: self codeWithBadIdentation.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRectoring named: 'iv6' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self deny: (sourceClass instVarNames includes: 'iv6').
	self assert: (targetClass instVarNames includes: 'iv6').
	self assert: 'iv6: anObject iv6 := anObject. ^anObject' equals: (targetClass compiledMethodAt: #iv6:) sourceCode.
	self assert: self expectedCodeWitBadIdentation equals: (sourceClass compiledMethodAt: #iv6:) sourceCode.
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/26/2022 19:10:47'!
test08CanMoveInstVarWhenThereAreTwoAssignationsOnSameMethod

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv6'.
	sourceClass compile: self setterWithTwoAssignations.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRectoring named: 'iv6' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self deny: (sourceClass instVarNames includes: 'iv6').
	self assert: (targetClass instVarNames includes: 'iv6').
	self assert: 'iv6: anObject iv6 := anObject. ^anObject' equals: (targetClass compiledMethodAt: #iv6:) sourceCode.
	self assert: self setterWithTwoAssignationsAfterRefactoring equals: (sourceClass compiledMethodAt: #iv6:) sourceCode.! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/26/2022 19:14:16'!
test09CanMoveInstVarWhenThereAreTwoAssignationsOnSameMethod

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
	self assert: 'iv6: anObject iv6 := anObject. ^anObject' equals: (targetClass compiledMethodAt: #iv6:) sourceCode.
	self assert: 'iv6: anObject
|tmpvar|
iv2 iv6: anObject.
tmpvar := anObject.
iv2 iv6: tmpvar.' equals: (sourceClass compiledMethodAt: #iv6:) sourceCode.

	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/26/2022 19:15:28'!
test10CanMoveInstVarWhenThereAreTwoReadReferencesToSourceIV

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

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/24/2022 16:31:38'!
test10CanMoveInstVarWhenThereIsAReadReferencesInAssignation

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

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/26/2022 19:20:36'!
test11CanMoveInstVarWhenThereIsAMixedReferencesToSourceIV

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

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/26/2022 19:22:54'!
test11_01CanMoveInstVarWhenThereIsAMixedReferencesToSourceIV

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

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/26/2022 19:26:11'!
test12SubClassReadMethodsShouldBeRefactored

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

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/26/2022 19:26:30'!
test12SubClassWriteMethodsShouldBeRefactored

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

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/20/2022 17:41:58'!
test13MixedMethodsShouldBeRefactored

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv5'.
	sourceClass compile: 'iv5
iv5 := 1.
^iv5'.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRectoring named: 'iv5' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self assert: 'iv5 ^iv5' equals: (targetClass compiledMethodAt: #iv5) sourceCode.
	self assert: 'iv5: anObject iv5 := anObject. ^anObject' equals: (targetClass compiledMethodAt: #iv5:) sourceCode.
	self assert: 'iv5
iv2 iv5: 1.
^iv2 iv5' equals: (sourceClass compiledMethodAt: #iv5) sourceCode.
! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/20/2022 17:42:10'!
test14MixedMethodsShouldBeRefactored

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
	
	self assert: 'iv5 ^iv5' equals: (targetClass compiledMethodAt: #iv5) sourceCode.
	self assert: 'iv5: anObject iv5 := anObject. ^anObject' equals: (targetClass compiledMethodAt: #iv5:) sourceCode.
	self assert: 'iv5
| tmp1 |
tmp1 := 1.
iv2 iv5: 1.
^iv2 iv5' equals: (sourceClass compiledMethodAt: #iv5) sourceCode.
! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/20/2022 17:42:18'!
test15MixedMethodsShouldBeRefactoredInSubclass

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
	
	self assert: 'iv5 ^iv5' equals: (targetClass compiledMethodAt: #iv5) sourceCode.
	self assert: 'iv5: anObject iv5 := anObject. ^anObject' equals: (targetClass compiledMethodAt: #iv5:) sourceCode.
	self assert: 'iv5
| tmp1 |
tmp1 := 1.
iv2 iv5: 1.
^iv2 iv5' equals: (sourceClass compiledMethodAt: #iv5) sourceCode.
! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 11/26/2022 01:28:40'!
test16WriteMethodsWithSameBlockCodeShouldBeRefactored

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

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 11/26/2022 01:28:39'!
test17MoveInstVarWithNoReadReferencesOnIVShouldNotCreateGetterOnTarget

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

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/20/2022 17:42:31'!
test18CanMoveInstVarWhenThereIsAWriteReferencesAndKeywordMessage

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
	
	self assert: 'iv1: anObject iv1 := anObject. ^anObject' equals: (targetClass compiledMethodAt: #iv1:) sourceCode.
	self assert: 
'iv1: anObject
	iv2 iv1: (iv3 byteAt: 2).
	iv3 := 1.
	^iv3.' equals: (sourceClass compiledMethodAt: #iv1:) sourceCode.
	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 11/27/2022 18:59:58'!
test19ThereAreOnly2VersionsAfterRefactoringMethodWithTwoWriteReferences

	| refactoring sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv6'.
	sourceClass compile: self setterWithTwoAssignations.
	targetClass := self createClassNamed: #TargetClass.
	
	refactoring := MoveInstanceVariableRectoring named: 'iv6' from: sourceClass to: targetClass accessingThrough: 'iv2'.
	refactoring apply.
	
	self assert: 2 equals: (VersionsBrowser versionCountForSelector: #iv6: class: sourceClass).! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 11/27/2022 19:00:24'!
test20ThereAreOnly2VersionsAfterRefactoringMethodWithTwoReadReferences

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

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 11/29/2022 00:05:54'!
test21ThereAreOnly2VersionsAfterRefactoringMethodWithMixedReferences

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

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/14/2022 00:30:06'!
test22ParenthesisShouldBeUsedOnDoubleAssignation

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

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/14/2022 00:34:13'!
test23ParenthesisShouldBeUsedOnDoubleAssignation

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

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/26/2022 20:55:31'!
test23_01ParenthesisShouldBeUsedOnDoubleAssignation

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

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/21/2022 02:29:44'!
test23_validation_getterMessageShouldntExistsOnTarget

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

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/21/2022 02:29:13'!
test24_validation_getterMessageShouldntExistsOnTarget

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

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/22/2022 17:43:22'!
test24_validation_getterMessageShouldntExistsOnTargetSuperclass

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

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/22/2022 19:24:26'!
test25_validation_instanceVariableShouldntExistsOnTarget

	| sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2 iv3'.
	targetClass := self createClassNamed: #TargetClass instanceVariableNames: 'iv2'.
	
	self 
		should: [MoveInstanceVariableRectoring named: 'iv2' from: sourceClass to: targetClass accessingThrough: 'iv3']
		raise: RefactoringError
		withExceptionDo: [ :error |
			self assert: MoveInstanceVariableRectoring instanceVariableExistsOnTargetHierarchyErrorMessage equals: error messageText ].
	

	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/22/2022 19:24:26'!
test26_validation_instanceVariableShouldntExistsOnTargetSubclass

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

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/22/2022 19:18:47'!
test27_validation_setterMessageShouldntExistsOnTarget

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

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/22/2022 22:16:10'!
test28_validation_instanceVariableToMoveShouldExistsOnSource

	| sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv2'.
	targetClass := self createClassNamed: #TargetClass.
	
	self 
		should: [MoveInstanceVariableRectoring named: 'iv1' from: sourceClass to: targetClass accessingThrough: 'iv2']
		raise: RefactoringError
		withExceptionDo: [ :error |
			self assert: MoveInstanceVariableRectoring instanceVariableToMoveShouldExistOnSourceClassErrorMessage equals: error messageText ].
	

	! !

!MoveInstanceVariableTest methodsFor: 'as yet unclassified' stamp: 'mc 12/22/2022 22:21:48'!
test29_validation_instanceVariableToAccessThroughShouldExistsOnSource

	| sourceClass targetClass |
	
	sourceClass := self createClassNamed: #SourceClass instanceVariableNames: 'iv1'.
	targetClass := self createClassNamed: #TargetClass.
	
	self 
		should: [MoveInstanceVariableRectoring named: 'iv1' from: sourceClass to: targetClass accessingThrough: 'iv2']
		raise: RefactoringError
		withExceptionDo: [ :error |
			self assert: MoveInstanceVariableRectoring instanceVariableToAccessThroughShouldExistOnSourceClassErrorMessage equals: error messageText ].
	

	! !


!classDefinition: #MoveInstanceVariableRectoring category: 'MoveInstanceVariableRefactoring'!
Object subclass: #MoveInstanceVariableRectoring
	instanceVariableNames: 'instVarNameSourceClass sourceClass targetClass instVarNameTargetClass'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'MoveInstanceVariableRefactoring'!

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


!MoveInstanceVariableRectoring methodsFor: 'private-createMethods' stamp: 'mc 10/11/2022 02:27:49'!
createGetterOnTargetClass

	^ targetClass compile: instVarNameSourceClass, ' ', '^', instVarNameSourceClass! !

!MoveInstanceVariableRectoring methodsFor: 'private-createMethods' stamp: 'mc 12/20/2022 17:38:35'!
createSetterOnTargetClass
	^ targetClass compile: instVarNameSourceClass, ': anObject ', instVarNameSourceClass, ' := anObject. ^anObject'.! !


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

!MoveInstanceVariableRectoring methodsFor: 'private-reading' stamp: 'mc 12/19/2022 13:53:24'!
replaceReadReferencesOnCompiledMethod: aCompiledMetthod
	| replacer newSource rangesToKeywords |
	replacer := InstanceVariableMixedReplacerVisitor 
				replace: instVarNameSourceClass 
				onMethod: aCompiledMetthod 
				accessingThrough: instVarNameTargetClass.
	rangesToKeywords := replacer execute.
	newSource := aCompiledMetthod sourceCode copyReplacing: rangesToKeywords.
	aCompiledMetthod methodClass compile: newSource.! !

!MoveInstanceVariableRectoring methodsFor: 'private-reading' stamp: 'mc 11/29/2022 02:02:39'!
replaceReadReferencesWithGettersOnSourceClass

	self readAccessInSourceClass do: [ :aCompiledMetthod | 
		self replaceReadReferencesOnCompiledMethod: aCompiledMetthod.
			].! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'MoveInstanceVariableRectoring class' category: 'MoveInstanceVariableRefactoring'!
MoveInstanceVariableRectoring class
	instanceVariableNames: ''!

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


!MoveInstanceVariableRectoring class methodsFor: 'instance creation' stamp: 'mc 12/22/2022 22:22:46'!
named: instVarNameSourceClass from: sourceClass to: targetClass accessingThrough: instVarNameTargetClass 
	(targetClass allSelectors includes: instVarNameSourceClass asSymbol) ifTrue: [ RefactoringError signal: self getterExistsOnTargetClassErrorMessage ].
	(targetClass allInstVarNamesEverywhere includes: instVarNameSourceClass) ifTrue: [ RefactoringError signal: self instanceVariableExistsOnTargetHierarchyErrorMessage ].
	(targetClass allSelectors includes: (instVarNameSourceClass,':') asSymbol) ifTrue: [ RefactoringError signal: self setterExistsOnTargetClassErrorMessage ].
	(sourceClass instVarNames includes: instVarNameSourceClass) ifFalse: [ RefactoringError signal: self instanceVariableToMoveShouldExistOnSourceClassErrorMessage ].
	(sourceClass instVarNames includes: instVarNameTargetClass) ifFalse: [ RefactoringError signal: self instanceVariableToAccessThroughShouldExistOnSourceClassErrorMessage ].
	^self new initializeNamed: instVarNameSourceClass from: sourceClass to: targetClass in: instVarNameTargetClass .! !
