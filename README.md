# IMP Interpreter

#### This is a lexical analyzer for the IMP langauge created using JFlex. Given an IMP program it will create it's syntactic tree and it will interpret it's result.

IMP Program:
``` 
int a;
a = 0;
if (!(a > 3)) {
	a = 1;
} else {}
```
Syntactic Tree:
```	
<MainNode>
	<SequenceNode>
		<AssignmentNode> =
			<VariableNode> a
			<IntNode> 0
		<IfNode> if
			<BracketNode> ()
				<NotNode> !
					<BracketNode> ()
						<GreaterNode> >
							<VariableNode> a
							<IntNode> 3
			<BlockNode> {}
				<AssignmentNode> =
					<VariableNode> a
					<IntNode> 1
			<BlockNode> {}
```
Result:
```
a=1;
```
