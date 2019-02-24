# IMP Interpreter

### This is a lexical analyzer for the IMP langauge created using JFlex. Given an IMP program it will create it's syntactic tree and it will interpret it's result.

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


### How to run:

Type the IMP program in a file named "input" and run the script "run.sh".
The syntactic tree will be written in a file named "tree" and the result in a file named "output".
