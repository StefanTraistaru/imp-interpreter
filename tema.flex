import java.util.*;
 
%%
 
%class TemaLexer
%standalone
%line
%{
	
	Stack<Expression> stack = new Stack<>();
    Stack<Integer> precedence = new Stack<>();
    ArrayList<String> variables = new ArrayList<>();

    // Intoarce al n-lea element de pe stiva
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

    // Elimina al doilea element de pe stiva "precedence"
    void pop_second() {
        int aux = precedence.pop();
        precedence.pop();
        precedence.push(aux);
    }

    // Verifica daca ";" sunt de la prima linie
    boolean check_declaration() {
        if (stack.peek() instanceof VarNode && stack.size() == 1) {
            variables.add( ((VarNode) stack.pop()).var);
            return true;
        }
        return false;
    }

    // Functie ajutatoare pentru "add_in_place"
    void add_sequence_node(Expression node) {
        Expression aux = stack.peek();
        while (((SequenceNode) aux).e2 instanceof SequenceNode) {
            aux = ((SequenceNode) aux).e2;
        }
        ((SequenceNode) aux).e2 = new SequenceNode(((SequenceNode) aux).e2, node);
    }

    // Adauga un element de tip Expression in arbore
    void add_in_place(Expression node) {

        // Daca arborele este gol se adauga noua expresie pe stiva
        if (stack.isEmpty()) {
            stack.push(node);
            return;
        }
        
        Expression aux = stack.peek();

        // Daca se mai afla o expresie pe stiva, se va scoate si se va adauga
        // un SequenceNode care le va contine pe ambele
        if (aux instanceof AssignmentNode ||
            aux instanceof IfNode ||
            aux instanceof WhileNode) {
            stack.push(new SequenceNode(stack.pop(), node));
            return;
        }

        // Daca se afla un SequenceNode pe stiva, noul nod va fi introdus
        // corespunzator in Sequence folosind functia ajutatoare "add_sequence_node"
        if (aux instanceof SequenceNode) {
            add_sequence_node(node);
            return;
        }

        // Verific daca nodul curent este un BlockNode
        // Daca face parte din while sau este al doilea din if
        // atunci voi crea un IfNode sau WhileNode si il voi pune pe stiva
        if (node instanceof BlockNode) {
            
            // Pentru if voi verifica daca varful stivei este un "else"
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

            // Pentru while
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

        // Daca nu este valabil niciun caz din cele de mai sus
        // nodul este adaugat pe stiva
        stack.push(node);
    }

    // Evalueaza toate operatiile de precedenta mai mare sau egala
    // sau pana la "=" sau "("
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

    // Cand se citeste o operatie, in functie de precedenta,
    // se va evalua sau nu expresia deja existenta
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
 
// Primitive
Number      = [1-9][0-9]* | 0
String      = (a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z)+
Var         = {String}
AVal        = {Number}
BVal        = "true" | "false"
Type        = "int"

// Simboluri
Equal       = "="
SemiCol     = ";"
Comma       = ","
Open_Par    = "("
Close_Par   = ")"
Open_Bl     = "{"
Close_Bl    = "}"

// Operatii
And         = "&&"
Not         = "!"
Greater     = ">"
Plus        = "+"
Divide      = "/"

// Conditii
While       = "while"
If          = "if"
Else        = "else"

%%

{Type}      { }

// Conditii
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

// Paranteze
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

// Operatii
{And}       {   evaluate_sign(1, "&&"); }
{Not}       {   evaluate_sign(2, "!"); }
{Greater}   {   evaluate_sign(3, ">"); }
{Plus}      {   evaluate_sign(4, "+"); }
{Divide}    {   evaluate_sign(5, "/"); }