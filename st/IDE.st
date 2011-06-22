Widget subclass: #TabManager
    ^tabs ifNil: [tabs := Array new]

    self setBodyMargin: '#jtalk' asJQuery height + 27

    {'jQuery(''#jtalk'').css(''top'', '''''').css(''bottom'', ''27px'');'}

    self setBodyMargin: 0

    '.jtalkBody' asJQuery cssAt: 'margin-bottom' put: anInteger asString, 'px'

    {'jQuery(''#jtalk'').resizable({
	handles: ''n'', 
	resize: aBlock,
	minHeight: 230
});'}

    {'jQuery(window).resize(aBlock)'}

    opened ifFalse: [
	self root asJQuery show.
	'body' asJQuery addClass: 'jtalkBody'.
	'#jtalk' asJQuery show.
	self updateBodyMargin.
	selectedTab root asJQuery show.
	opened := true]

    opened ifTrue: [
	self root asJQuery hide.
	'#jtalk' asJQuery hide.
	self removeBodyMargin.
	'body' asJQuery removeClass: 'jtalkBody'.
	opened := false]

    Browser open

    self open.
    selectedTab := aWidget.
    self tabs do: [:each |
	each root asJQuery hide].
    aWidget root asJQuery show.
    self update

    self removeTab: aWidget.
    self selectTab: self tabs last.
    aWidget root asJQuery remove.
    self update

    self tabs add: aWidget.
    '#jtalk' asJQuery append: aWidget.
    aWidget root asJQuery hide

    self tabs remove: aWidget.
    self update

    super initialize.
    opened := true.
    'body' asJQuery 
	append: self;
	append: [:html | html div id: 'jtalk'];
	addClass: 'jtalkBody'.
    self 
	addTab: Transcript current;
	addTab: Workspace new.
    self selectTab: self tabs last.
    self 
	onResize: [self updateBodyMargin; updatePosition];
	onWindowResize: [self updatePosition]

    html ul
	id: 'jtalkTabs';
	with: [
	    html li 
		class: 'closeAll';
		with: 'x';
		onClick: [self close].
	    self tabs do: [:each |
		self renderTabFor: each on: html].
	    html li
		class: 'newtab';
		with: ' + ';
		onClick: [self newBrowserTab]]

    | li |
    li := html li.
    selectedTab = aWidget ifTrue: [
	li class: 'selected'].
    li with: [
	html span
	    with: aWidget label;
	    onClick: [self selectTab: aWidget].
	aWidget canBeClosed ifTrue: [
	    html span 
		class: 'close';
		with: 'x';
		onClick: [self closeTab: aWidget]]]

    ^current ifNil: [current := super new]

    self shouldNotImplement

    self subclassResponsibility

    TabManager current
	addTab: self;
	selectTab: self

    html root
	class: 'jtalkTool';
	with: [
	    html div
		class: 'jt_box';
		with: [self renderBoxOn: html].
	    html div
		class: 'jt_buttons';
		with: [self renderButtonsOn: html]]



    ^false

    ^self new open

    ^'[Workspace]'

    {'return document.selection'}

    {'return jQuery(''.jt_workspace'')[0].selectionStart'}

    {'return jQuery(''.jt_workspace'')[0].selectionEnd'}

    {'jQuery(''.jt_workspace'')[0].selectionStart = anInteger'}

    {'jQuery(''.jt_workspace'')[0].selectionEnd = anInteger'}

    | lines startLine endLine|
    lines := textarea asJQuery val tokenize: String cr.
    startLine := endLine := 0.
    lines do: [:each |
	endLine := startLine + each size.
	startLine := endLine + 1.
	endLine >= self selectionStart ifTrue: [
	    self selectionEnd: endLine.
	    ^each]]

    {'if(anEvent.ctrlKey) {
		if(anEvent.keyCode === 80) { //ctrl+p
			self._printIt();
			anEvent.preventDefault();
			return false;
		}
		if(anEvent.keyCode === 68) { //ctrl+d
			self._doIt();
			anEvent.preventDefault();
			return false;
		}
		if(anEvent.keyCode === 73) { //ctrl+i
			self._inspectIt();
			anEvent.preventDefault();
			return false;
		}
	}'}

    textarea asJQuery val: ''

    | selection |
    textarea asJQuery focus.
    self selectionStart = self selectionEnd
	ifTrue: [selection := self currentLine]
	ifFalse: [
	    selection := textarea asJQuery val copyFrom: self selectionStart + 1 to: self selectionEnd + 1].
    ^self eval: selection
    self print: self doIt printString

    | start |
    start := self selectionEnd.
    textarea asJQuery val: (
	(textarea asJQuery val copyFrom: 1 to: start),
	' ', aString, ' ',
	(textarea asJQuery val copyFrom: start + 1 to: textarea asJQuery val size)).
    self selectionStart: start.
    self selectionEnd: start + aString size + 2

    | compiler node |
    compiler := Compiler new.
    node := compiler parseExpression: aString.
    node isParseFailure ifTrue: [
	^self alert: node reason, ', position: ', node position].
    ^compiler loadExpression: aString

    self doIt inspect

    textarea := html textarea.
    textarea asJQuery call: 'tabby'.
    textarea onKeyDown: [:e | self handleKeyDown: e].
    textarea 
	class: 'jt_workspace';
	at: 'spellcheck' put: 'false'

    html button
	with: 'DoIt';
	title: 'ctrl+d';
	onClick: [self doIt].
    html button
	with: 'PrintIt';
	title: 'ctrl+p';
	onClick: [self printIt].
    html button
	with: 'InspectIt';
	title: 'ctrl+i';
	onClick: [self inspectIt].
    html button
	with: 'Clear workspace';
	onClick: [self clearWorkspace]

    ^'[Transcript]'

    textarea asJQuery val: textarea asJQuery val, anObject asString.


    textarea asJQuery val: textarea asJQuery val, String cr.

    textarea asJQuery val: ''

    textarea := html textarea.
    textarea asJQuery call: 'tabby'.
    textarea 
	class: 'jt_transcript';
	at: 'spellcheck' put: 'false'

    html button
	with: 'Clear transcript';
	onClick: [self clear]

    self current open

    self shouldNotImplement

    ^current ifNil: [current := super new]

    self current show: anObject

    self current show: String cr

    self current clear

    ^selectedClass 
	ifNil: ['Browser (nil)']
	ifNotNil: [selectedClass name]

    | categories |
    categories := Array new.
    Smalltalk current classes do: [:each |
	(categories includes: each category) ifFalse: [
	    categories add: each category]].
    ^categories sort

    ^(Smalltalk current classes 
	select: [:each | each category = selectedCategory])
	sort: [:a :b | a name > b name]

    | klass |
    selectedClass ifNotNil: [
	selectedTab = #comment ifTrue: [^#()].
	klass := selectedTab = #instance
	    ifTrue: [selectedClass]
	    ifFalse: [selectedClass class].
	klass methodDictionary isEmpty ifTrue: [
	    ^Array with: 'not yet classified'].
	^klass protocols].
    ^Array new
    | klass |
    selectedTab = #comment ifTrue: [^#()].
    selectedClass ifNotNil: [
	klass := selectedTab = #instance
	    ifTrue: [selectedClass]
	    ifFalse: [selectedClass class]].
    ^(selectedProtocol 
	ifNil: [
	    klass 
		ifNil: [#()] 
		ifNotNil: [klass methodDictionary values]]
	ifNotNil: [
	    klass methodDictionary values select: [:each |
		each category = selectedProtocol]]) sort: [:a :b | a selector > b selector]

    selectedTab = #comment ifFalse: [
	^(selectedProtocol notNil or: [selectedMethod notNil])
	    ifFalse: [self declarationSource]
	    ifTrue: [self methodSource]].
    ^selectedClass
	ifNil: ['']
	ifNotNil: [self classCommentSource]

    ^selectedMethod
	ifNil: [self dummyMethodSource]
	ifNotNil: [selectedMethod source]

    ^'messageSelectorAndArgumentNames
	"comment stating purpose of message"

	| temporary variable names |
	statements'

    ^selectedTab = #instance
	ifTrue: [self classDeclarationSource]
	ifFalse: [self metaclassDeclarationSource]

    | stream |
    stream := '' writeStream.
    selectedClass ifNotNil: [
	stream 
	    nextPutAll: selectedClass superclass asString;
	    nextPutAll: ' subclass: #';
	    nextPutAll: selectedClass name;
	    nextPutAll: String cr, String tab;
	    nextPutAll: 'instanceVariableNames: '''.
	selectedClass instanceVariableNames 
	    do: [:each | stream nextPutAll: each] 
	    separatedBy: [stream nextPutAll: ' '].
	stream
	    nextPutAll: '''', String cr, String tab;
	    nextPutAll: 'category: ''';
	    nextPutAll: selectedClass category;
	    nextPutAll: ''''].
    ^stream contents

    | stream |
    stream := '' writeStream.
    selectedClass ifNotNil: [
	stream 
	    nextPutAll: selectedClass asString;
	    nextPutAll: ' class ';
	    nextPutAll: 'instanceVariableNames: '''.
	selectedClass class instanceVariableNames
	    do: [:each | stream nextPutAll: each]
	    separatedBy: [stream nextPutAll: ' '].
	stream nextPutAll: ''''].
    ^stream contents

    ^selectedClass comment

    saveButton removeAt: 'disabled'.
    unsavedChanges := true

    saveButton ifNotNil: [
	saveButton at: 'disabled' put: true].
    unsavedChanges := false

    classButtons asJQuery hide

    classButtons asJQuery show

    methodButtons asJQuery hide

    methodButtons asJQuery show

    self disableSaveButton.
    selectedTab = #comment ifTrue: [
	selectedClass ifNotNil: [
	    self compileClassComment]].
    (selectedProtocol notNil or: [selectedMethod notNil])
	ifFalse: [self compileDefinition]
	ifTrue: [self compileMethodDefinition]

    selectedClass comment: sourceTextarea asJQuery val

    selectedTab = #instance
	ifTrue: [self compileMethodDefinitionFor: selectedClass]
	ifFalse: [self compileMethodDefinitionFor: selectedClass class]

    | compiler method source node |
    source := sourceTextarea asJQuery val.
    selectedProtocol ifNil: [selectedProtocol := selectedMethod category].
    compiler := Compiler new.
    node := compiler parse: source.
    node isParseFailure ifTrue: [
	^self alert: 'PARSE ERROR: ', node reason, ', position: ', node position asString].
    compiler currentClass: selectedClass.
    method := compiler eval: (compiler compileNode: node).
    method category: selectedProtocol.
    compiler unknownVariables do: [:each |
	(self confirm: 'Declare ''', each, ''' as instance variable?') ifTrue: [
		self addInstanceVariableNamed: each toClass: aClass.
		^self compileMethodDefinitionFor: aClass]].
    aClass addCompiledMethod: method.
    self updateMethodsList.
    self selectMethod: method

    | newClass |
    newClass := Compiler new loadExpression: sourceTextarea asJQuery val.
    self 
	updateCategoriesList;
	updateClassesList

    selectedCategory ifNotNil: [
	(Ajax url: self class commitPathJs, '/', selectedCategory, '.js')
	    at: 'type' put: 'PUT';
	    at: 'data' put: (Exporter new exportCategory: selectedCategory);
	    at: 'error' put: [self alert: 'Commit failed!'];
	    send.
	(Ajax url: self class commitPathSt, '/', selectedCategory, '.st')
	    at: 'type' put: 'PUT';
	    at: 'data' put: (ChunkExporter new exportCategory: selectedCategory);
	    at: 'error' put: [self alert: 'Commit failed!'];
	    send]

    ^unsavedChanges 
	ifTrue: [self confirm: 'Cancel changes?']
	ifFalse: [true]

    (self confirm: 'Do you really want to remove ', selectedClass name, '?')
	ifTrue: [
	    Smalltalk current basicDelete: selectedClass name.
	    self selectClass: nil]

    self cancelChanges ifTrue: [
	(self confirm: 'Do you really want to remove #', selectedMethod selector, '?')
	    ifTrue: [
		selectedTab = #instance 
			ifTrue: [selectedClass removeCompiledMethod: selectedMethod]
			ifFalse: [selectedClass class removeCompiledMethod: selectedMethod].
		self selectMethod: nil]]

    self cancelChanges ifTrue: [
	(self protocols includes: aString)
	    ifFalse: [self addNewProtocol]
	    ifTrue: [
		selectedMethod category: aString.
		selectedProtocol := aString.
		selectedMethod := selectedMethod.
		self 
		    updateProtocolsList;
		    updateMethodsList;
		    updateSourceAndButtons]]

    | newProtocol |
    newProtocol := self prompt: 'New method protocol'.
    newProtocol notEmpty ifTrue: [
	selectedMethod category: newProtocol.
	self setMethodProtocol: newProtocol]

    self cancelChanges ifTrue: [
	selectedCategory := aCategory.
	selectedClass := selectedProtocol := selectedMethod :=  nil.
	self 
	    updateCategoriesList;
	    updateClassesList;
	    updateProtocolsList;
	    updateMethodsList;
	    updateSourceAndButtons]

    self cancelChanges ifTrue: [
	selectedClass := aClass.
	selectedProtocol := selectedMethod := nil.
	self 
	    updateClassesList;
	    updateProtocolsList;
	    updateMethodsList;
	    updateSourceAndButtons]

    self cancelChanges ifTrue: [
	selectedProtocol := aString.
	selectedMethod := nil.
	self 
	    updateProtocolsList;
	    updateMethodsList;
	    updateSourceAndButtons]

    self cancelChanges ifTrue: [
	selectedMethod := aMethod.
	self 
	    updateProtocolsList;
	    updateMethodsList;
	    updateSourceAndButtons]

    self cancelChanges ifTrue: [
	selectedTab := aString.
	self selectProtocol: nil.
	self updateTabsList]

    | newName |
    newName := self prompt: 'Rename class ', selectedClass name.
    newName notEmpty ifTrue: [
	selectedClass rename: newName.
	self 
		updateClassesList;
		updateSourceAndButtons]

	ClassBuilder new
		addSubclassOf: aClass superclass named: aClass name instanceVariableNames: (aClass instanceVariableNames copy add: aString; yourself)
	ReferencesBrowser search: aString
	ReferencesBrowser search: selectedClass name
    super initialize.
    selectedTab := #instance.
    unsavedChanges := false

    self 
	renderTopPanelOn: html;
	renderTabsOn: html;
	renderBottomPanelOn: html

    html div 
	class: 'top'; 
	with: [
	    categoriesList := html ul class: 'jt_column categories'.
	    commitButton := html button 
		class: 'jt_commit';
		title: 'Commit classes in this category to disk';
		onClick: [self commitCategory];
		with: 'Commit category'.
	    classesList := html ul class: 'jt_column classes'.
	    protocolsList := html ul class: 'jt_column protocols'.
	    methodsList := html ul class: 'jt_column methods'.
	    self
		updateCategoriesList;
		updateClassesList;
		updateProtocolsList;
		updateMethodsList.
	    html div class: 'jt_clear']

    tabsList := html ul class: 'jt_tabs'.
    self updateTabsList.

    html div
	class: 'jt_sourceCode';
	with: [
	    sourceTextarea := html textarea 
		onKeyPress: [self enableSaveButton];
		class: 'source';
		at: 'spellcheck' put: 'false'.
	    sourceTextarea asJQuery call: 'tabby']

    saveButton := html button.
    saveButton 
	with: 'Save';
	onClick: [self compile].
    methodButtons := html span.
    classButtons := html span.
    self updateSourceAndButtons

    ^true

    categoriesList contents: [:html |
	self categories do: [:each || li label |
	    each isEmpty 
		ifTrue: [label := 'Unclassified']
		ifFalse: [label := each].
	    li := html li.
	    selectedCategory = each ifTrue: [
		li class: 'selected'].
	    li
		with: label;
		onClick: [self selectCategory: each]]]

    TabManager current update.
    classesList contents: [:html |
	self classes do: [:each || li |
	    li := html li.
	    selectedClass = each ifTrue: [
		li class: 'selected'].
	    li
		with: each name;
		onClick: [self selectClass: each]]]

    protocolsList contents: [:html |
	self protocols do: [:each || li |
	    li := html li.
	    selectedProtocol = each ifTrue: [
		li class: 'selected'].
	    li 
		with: each;
		onClick: [self selectProtocol: each]]]

    methodsList contents: [:html |
	self methods do: [:each || li |
	    li := html li.
	    selectedMethod = each ifTrue: [
		li class: 'selected'].
	    li
		with: each selector;
		onClick: [self selectMethod: each]]]

    tabsList contents: [:html || li |
	li := html li.
	selectedTab = #instance ifTrue: [li class: 'selected'].
	li
	    with: 'Instance';
	    onClick: [self selectTab: #instance].
	li := html li.
	selectedTab = #class ifTrue: [li class: 'selected'].
	li
	    with: 'Class';
	    onClick: [self selectTab: #class].
	li := html li.
	selectedTab = #comment ifTrue: [li class: 'selected'].
	li
	    with: 'Comment';
	    onClick: [self selectTab: #comment]]

	self disableSaveButton.
	classButtons contents: [:html |
		html button
			with: 'Rename class';
			onClick: [self renameClass].
		html button
			with: 'Remove class';
			onClick: [self removeClass].
		html button
			with: 'References';
			onClick: [self searchClassReferences]].
	methodButtons contents: [:html |
		html button
			with: 'Remove method';
			onClick: [self removeMethod].
		html select 
	    		onChange: [:e :select | self setMethodProtocol: select val];
	    		with: [
				html option
		    			with: 'Method protocol';
					at: 'disabled' put: 'disabled'.
				html option
		    			class: 'important';
		    			with: 'New...'.
				self protocols do: [:each |
		    			html option with: each]].
		selectedMethod isNil ifFalse: [
			html select 
	    			onChange: [:e :select | self searchReferencesOf: select val];
	    			with: [
					html option
		    				with: 'References';
						at: 'disabled' put: 'disabled'.
					html option
		    				class: 'important';
		    				with: selectedMethod selector.
					selectedMethod messageSends sorted do: [:each |
		    				html option with: each]]]].
    	selectedMethod isNil
		ifTrue: [
	    		self hideMethodButtons.
	    			(selectedClass isNil or: [selectedProtocol notNil])
					ifTrue: [self hideClassButtons]
	    				ifFalse: [self showClassButtons]]
		ifFalse: [
	    		self hideClassButtons.
	    		self showMethodButtons].
    	sourceTextarea asJQuery val: self source

	^'js'
	^'st'
    ^self new
	open;
	selectCategory: aClass category;
	selectClass: aClass

    self new open

	^label ifNil: ['Inspector (nil)']
	^variables
	variables := aCollection
	label := aString
	^selectedVariable
	selectedVariable := aString
	object := anObject.
	variables := #().
	object inspectOn: self
	(self variables at: self selectedVariable) inspect
	self 
		inspect: object; 
		updateVariablesList;
		updateValueTextarea
	self 
		renderTopPanelOn: html;
		renderBottomPanelOn: html
    html div 
	class: 'top'; 
	with: [
	    variablesList := html ul class: 'jt_column variables'.
	    valueTextarea := html textarea class: 'jt_column value'; at: 'readonly' put: 'readonly'.
	    self
		updateVariablesList;
		updateValueTextarea.
	    html div class: 'jt_clear']

    html div
	class: 'jt_sourceCode';
	with: [
	    workspaceTextarea := html textarea 
		class: 'source';
		at: 'spellcheck' put: 'false'.
	    workspaceTextarea asJQuery call: 'tabby']

	html button
		with: 'Refresh';
		onClick: [self refresh].
	diveButton := html button 
		with: 'Dive'; 
		onClick: [self dive].
	self updateButtons
	
	^true
	variablesList contents: [:html |
		self variables keys do: [:each || li |
			li := html li.
			li
				with: each;
				onClick: [self selectVariable: each].
			self selectedVariable = each ifTrue: [
				li class: 'selected']]]
	self selectedVariable: aString.
	self 
		updateVariablesList;
		updateValueTextarea;
		updateButtons
	valueTextarea asJQuery val: (self selectedVariable isNil
		ifTrue: ['']
		ifFalse: [(self variables at: self selectedVariable) printString])
	(self selectedVariable notNil and: [(self variables at: self selectedVariable) notNil])
		ifFalse: [diveButton at: 'disabled' put: true] 
		ifTrue: [diveButton removeAt: 'disabled']
		
	^self new
		inspect: anObject;
		yourself
	^implementors ifNil: [implementors := Array new]
	^'[ReferencesBrowser]'
	^selector
	^senders ifNil: [senders := Array new]
	^Smalltalk current classes, (Smalltalk current classes collect: [:each | each class])
	^referencedClasses ifNil: [referencedClasses := Array new]
       | browser |
       browser := Browser openOn: (aMethod class isMetaclass 
		ifTrue: [aMethod methodClass instanceClass] ifFalse: [aMethod methodClass]).
       aMethod methodClass isMetaclass ifTrue: [browser selectTab: #class].
       browser
               selectProtocol: aMethod category;
               selectMethod: aMethod
	selector := aString.
	implementors := Array new.
	senders := Array new.
	referencedClasses := Array new.
	(selector match: '^[A-Z]') 
		ifFalse: [self searchSelectorReferencesFor: selector]
		ifTrue: [self searchReferencedClassesFor: selector]
	self 
		searchReferencesFor: aString;
		updateImplementorsList;
		updateSendersList;
		updateReferencedClassesList
	self classesAndMetaclasses do: [:each |
		each methodDictionary values do: [:value |
			(((value referencedClasses select: [:each | each notNil])collect: [:each | each name]) includes: selector) ifTrue: [
				self referencedClasses add: value]]]
	self classesAndMetaclasses do: [:each | 
		each methodDictionary keysAndValuesDo: [:key :value | 
			key = selector ifTrue: [self implementors add: value]].
		each methodDictionary keysAndValuesDo: [:key :value | 
			(value messageSends includes: selector) ifTrue: [
				self senders add: value]]]
	super initialize.
	selector := ''
	input
		onKeyUp: [timer := [self search: input asJQuery val] valueWithTimeout: 100];
		onKeyDown: [timer ifNotNil: [timer clearTimeout]]
	self 
		renderInputOn: html;
		renderImplementorsOn: html;
		renderSendersOn: html;
		renderReferencedClassesOn: html
	input := html input 
		class: 'implementors';
		yourself.
	input asJQuery val: selector.
	self setInputEvents
    	implementorsList := html ul class: 'jt_column implementors'.
	self updateImplementorsList
    	sendersList := html ul class: 'jt_column senders'.
	self updateSendersList
    	referencedClassesList := html ul class: 'jt_column referenced_classes'.
	self updateReferencedClassesList
	^true
    implementorsList contents: [:html |
	html li
		class: 'column_label'; 
		with: 'Implementors';
		style: 'font-weight: bold'.
	self implementors do: [:each || li |
	    li := html li.
	    li
		with: (each methodClass asString, ' >> ', self selector);
		onClick: [self openBrowserOn: each]]]
    	sendersList contents: [:html |
	html li
		class: 'column_label'; 
		with: 'Senders';
		style: 'font-weight: bold'.
	self senders do: [:each |
		html li
	    		with: (each methodClass asString, ' >> ', each selector);
			onClick: [self openBrowserOn: each]]]
    	referencedClassesList contents: [:html |
	html li
		class: 'column_label'; 
		with: 'Class references';
		style: 'font-weight: bold'.
	self referencedClasses do: [:each |
		html li
	    		with: (each methodClass asString, ' >> ', each selector);
			onClick: [self openBrowserOn: each]]]
	^self new
		searchReferencesFor: aString;
		open
	Inspector new 
		inspect: self;
		open
	| variables |
	variables := Dictionary new.
	variables at: '#self' put: self.
	self class instanceVariableNames do: [:each |
		variables at: each put: (self instVarAt: each)].
	anInspector 
		setLabel: self printString;
		setVariables: variables
	
	
	| variables |
	variables := Dictionary new.
	variables at: '#self' put: self.
	variables at: '#year' put: self year.
	variables at: '#month' put: self month.
	variables at: '#day' put: self day.
	variables at: '#hours' put: self hours.
	variables at: '#minutes' put: self minutes.
	variables at: '#seconds' put: self seconds.
	variables at: '#milliseconds' put: self milliseconds.
	anInspector 
		setLabel: self printString;
		setVariables: variables
	
	
	| variables |
	variables := Dictionary new.
	variables at: '#self' put: self.
	self withIndexDo: [:each :i |
		variables at: i put: each].
	anInspector 
		setLabel: self printString;
		setVariables: variables
	| label |
	super inspectOn: anInspector.
	self printString size > 30 
		ifTrue: [label := (self printString copyFrom: 1 to: 30), '...''']
		ifFalse: [label := self printString]. 
	anInspector setLabel: label
	| variables |
	variables := Dictionary new.
	variables at: '#self' put: self.
	variables at: '#keys' put: self keys.
	self keysAndValuesDo: [:key :value |
		variables at: key put: value].
	anInspector 
		setLabel: self printString;
		setVariables: variables