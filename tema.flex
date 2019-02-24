import java.util.*;
 
%%
 
%class TemaLexer
%standalone
%line
%{
	
	Stack<Expression> stack = new Stack<>();
    Stack<Integer> precedence = new Stack<>();
    ArrayList<String> variables = new ArrayList<>();

    // Returns the n-th element from stack
	Expression get_nth_element_from_stack(int element_number) {
        Stack<Expression> temp_stack = new Stack<>();

        if (element_number > stack.size()) {
            return null;
        }

        for (int j = 0; j < element_number; ++j) {
            temp_stack.push(stack.pop());
        }

        Expression res = temp_stack.peek();

        for (int j = 0; j < element_number; ++j) {
            stack.push(temp_stack.pop());
        }
        return res;
    }

    // Removes the second element from the "precedence" stack
    void pop_second() {
        int aux = precedence.pop();
        precedence.pop();
        precedence.push(aux);
    }

    // Checks if the ";" symbol is from the first line (variable declaration line)
    boolean check_declaration() {
        if (stack.peek() instanceof VarNode && stack.size() == 1) {
            variables.add( ((VarNode) stack.pop()).var);
            return true;
        }
        return false;
    }

    // Helper function for "add_in_place"
    void add_sequence_node(Expression node) {
        Expression aux = stack.peek();
        while (((SequenceNode) aux).e2 instanceof SequenceNode) {
            aux = ((SequenceNode) aux).e2;
        }
        ((SequenceNode) aux).e2 = new SequenceNode(((SequenceNode) aux).e2, node);
    }

    // Adding an Expression element in the tree
    void add_in_place(Expression node) {

        // If the tree is empty add the new expression from the stack
        if (stack.isEmpty()) {
            stack.push(node);
            return;
        }
        
        Expression aux = stack.peek();

		// If there is another expression on the stack, it will be removed and
		// a SequenceNode containing the old expression and the new one will be added.
        if (aux instanceof AssignmentNode ||
            aux instanceof IfNode ||
            aux instanceof WhileNode) {
            stack.push(new SequenceNode(stack.pop(), node));
            return;
        }

		// If there is a SequenceNode on the stack, the new node will be placed
		// in the SequenceNode using the "add_sequence_node" function
        if (aux instanceof SequenceNode) {
            add_sequence_node(node);
            return;
        }

		// Checking if the current node is a BlockNode
		// If it is a part of a "while" or it is the second blocknode from an "if"
		// the it will create an IfNode or a WhileNode and put it on the stack
        if (node instanceof BlockNode) {
            
			// For "if" it checks if the top of the stack is an "else"
            if (stack.peek() instanceof SymbolNode &&
               ((SymbolNode)stack.peek()).symbol == "else") {
                stack.pop(); // Scot "else"
                aux = stack.pop(); // If BlockNode
                Expression aux2 = stack.pop(); // If BracketNode
                stack.pop(); // Scot "if"
                IfNode new_node = new IfNode(aux2, (BlockNode)aux, (BlockNode)node);
                add_in_place(new_node);
                return;
            }

            // For "while"
            aux = get_nth_element_from_stack(2);
            if (aux instanceof SymbolNode &&
               ((SymbolNode)aux).symbol == "while") {
                aux = stack.pop(); // While BracketNode
                stack.pop(); // Scot "while"
                WhileNode new_node = new WhileNode(aux, (BlockNode)node);
                add_in_place(new_node);
                return;
            }
        }

		// If it's none of the above, the node will be added to the stack
        stack.push(node);
    }

	// Evaluates all the operations with a higher or equal precedence
	// or until a "=" or "(" symbol
    void evaluate_before() {
        Expression e = get_nth_element_from_stack(2);

        while (e instanceof SymbolNode) {

            if ( ((SymbolNode)e).symbol == "=" ||
                 ((SymbolNode)e).symbol == "(") {
                return;
            }
            Expression e1 = stack.pop();
            SymbolNode x = (SymbolNode) stack.pop();
            
            if (x.symbol == "&&" && precedence.peek() <= 1) {
                Expression e2 = stack.pop();
                pop_second();
                stack.push(new AndNode(e2, e1));
                e = get_nth_element_from_stack(2);
                continue;
            }
            if (x.symbol == "!" && precedence.peek() <= 2) {
                stack.push(new NotNode(e1));
                pop_second();
                e = get_nth_element_from_stack(2);
                continue;
            }
            if (x.symbol == ">" && precedence.peek() <= 3) {
                Expression e2 = stack.pop();
                pop_second();
                stack.push(new GreaterNode(e2, e1));
                e = get_nth_element_from_stack(2);
                continue;
            }
            if (x.symbol == "+" && precedence.peek() <= 4) {
                Expression e2 = stack.pop();
                pop_second();
                stack.push(new PlusNode(e2, e1));
                e = get_nth_element_from_stack(2);
                continue;
            }
            if (x.symbol == "/" && precedence.peek() <= 5) {
                Expression e2 = stack.pop();
                pop_second();
                stack.push(new DivNode(e2, e1));
                e = get_nth_element_from_stack(2);
                continue;
            }
            stack.push(x);
            stack.push(e1);
            return;
        }
    }

	// When an operation is read, it will evaluate the existing expression
	// based on the precedence of the operation
    void evaluate_sign(int prec, String symbol) {
        if (!precedence.isEmpty() && precedence.peek() >= prec) {
            precedence.push(prec);
            evaluate_before();
        } else {
            precedence.push(prec);
        }
        stack.push(new SymbolNode(symbol));
    }

%}
 
// Primitives
Number      = [1-9][0-9]* | 0
String      = (a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z)+
Var         = {String}
AVal        = {Number}
BVal        = "true" | "false"
Type        = "int"

// Symbols
Equal       = "="
SemiCol     = ";"
Comma       = ","
Open_Par    = "("
Close_Par   = ")"
Open_Bl     = "{"
Close_Bl    = "}"

// Operations
And         = "&&"
Not         = "!"
Greater     = ">"
Plus        = "+"
Divide      = "/"

// Conditions
While       = "while"
If          = "if"
Else        = "else"

%%

{Type}      { }

// Conditions
{While}     {   stack.push(new SymbolNode("while")); }
{If}        {   stack.push(new SymbolNode("if")); }
{Else}      {   stack.push(new SymbolNode("else")); }


{AVal}      { stack.push(new IntNode(yytext())); }
{BVal}      { stack.push(new BoolNode(yytext())); }
{Var} 		{ stack.push(new VarNode(yytext())); }

{Equal}		{ stack.push(new SymbolNode("=")); }
{Comma}     {   VarNode x = (VarNode) stack.pop();
                variables.add(x.var); 
            }
{SemiCol}	{   
                if (! check_declaration()) {
                    precedence.push(-1);
                    evaluate_before();
                    precedence.pop();
                    Expression e1 = stack.pop();
                    stack.pop();
                    Expression e2 = stack.pop();
                    AssignmentNode node = new AssignmentNode(e2, e1);
                    add_in_place(node);
                }
            }

// Parentheses
{Open_Par}  { stack.push(new SymbolNode("(")); }
{Close_Par} {   
                precedence.push(-1);
                evaluate_before();
                precedence.pop();
                BracketNode aux = new BracketNode(stack.pop());
                stack.pop(); // Sterge "(" din stiva
                stack.push(aux);
            }

// Block
{Open_Bl}   { stack.push(new SymbolNode("{")); }
{Close_Bl}  {
                if (stack.peek() instanceof SymbolNode &&
                    ((SymbolNode)stack.peek()).symbol == "{" ) {
                    stack.pop(); // Sterge "{" din stiva
                    add_in_place(new BlockNode(null));
                } else { 
                    BlockNode node = new BlockNode(stack.pop());
                    stack.pop(); // Sterge "{" din stiva
                    add_in_place(node);
                }
            }

// Operations
{And}       {   evaluate_sign(1, "&&"); }
{Not}       {   evaluate_sign(2, "!"); }
{Greater}   {   evaluate_sign(3, ">"); }
{Plus}      {   evaluate_sign(4, "+"); }
{Divide}    {   evaluate_sign(5, "/"); }
