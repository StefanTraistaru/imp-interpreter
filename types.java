
abstract interface Expression {
	String show();
	int interpret();
};

class SymbolNode implements Expression {
	String symbol;

	public SymbolNode(String symbol) {
		super();
		this.symbol = symbol;
	}
	
	String symbol() {
		return symbol;
	}

	@Override
	public String show() {
		return symbol + "\n";
	}
	
	@Override
	public int interpret() {
		return 0;
	}
};

class MainNode implements Expression {
	Expression e;
	
	public MainNode(Expression e) {
		super();
		this.e = e;
	}
	
	@Override
	public String show() {
		String build = "";
		build += "<MainNode>\n";
		
		String print = "";
		print += e.show();
		
		build += Main.addNewline(print); 
		return build;
	}

	@Override
	public int interpret() {
		return 0;
	}
};

class IntNode implements Expression {
	String number;
	
	public IntNode(String number) {
		super();
		this.number = number;
	}
	
	@Override
	public String show() {
		return "<IntNode> " + this.number + "\n";
	}

	@Override
	public int interpret() {
		return Integer.parseInt(number);
	}
};

class BoolNode implements Expression {
	String value;
	
	public BoolNode(String value) {
		super();
		this.value = value;
	}
	
	@Override
	public String show() {
		return "<BoolNode> " + this.value + "\n";
	}

	@Override
	public int interpret() {
		if (value.equals("true")) {
			return 1;
		}
		return 0;
	}
};

class VarNode implements Expression {
	String var;
	
	public VarNode(String var) {
		super();
		this.var = var;
	}
	
	@Override
	public String show() {
		return "<VariableNode> " + this.var + "\n";
	}

	@Override
	public int interpret() {
		if (Main.values.containsKey(var)) {
			if (Main.values.get(var) != null) {
				return Main.values.get(var);
			}
		}
		return 0;
	}
};

class PlusNode implements Expression {
	Expression e1, e2;
	
	public PlusNode(Expression e1, Expression e2) {
		super();
		this.e1 = e1;
		this.e2 = e2;
	}
	
	@Override
	public String show() {
		String build = "";
		build += "<PlusNode> +\n";
		
		String print = "";
		print += e1.show() + e2.show();
		
		build += Main.addNewline(print); 
		return build;
	}

	@Override
	public int interpret() {
		return e1.interpret() + e2.interpret();
	}
};

class DivNode implements Expression {
	Expression e1, e2;
	
	public DivNode(Expression e1, Expression e2) {
		super();
		this.e1 = e1;
		this.e2 = e2;
	}
	
	@Override
	public String show() {
		String build = "";
		build += "<DivNode> /\n";
		
		String print = "";
		print += e1.show() + e2.show();
		
		build += Main.addNewline(print); 
		return build;
	}

	@Override
	public int interpret() {
		if (e2.interpret() == 0) {
			return 0;
		}
		return e1.interpret() / e2.interpret();
	}
};

class BracketNode implements Expression {
	Expression e;
	
	public BracketNode(Expression e) {
		super();
		this.e = e;
	}
	
	@Override
	public String show() {
		String build = "";
		build += "<BracketNode> ()\n";
		
		String print = "";
		print += e.show();
		
		build += Main.addNewline(print); 
		return build;
	}

	@Override
	public int interpret() {
		return e.interpret();
	}
};

class AndNode implements Expression {
	Expression e1, e2;

	public AndNode(Expression e1, Expression e2) {
		super();
		this.e1 = e1;
		this.e2 = e2;
	}

	@Override
	public String show() {
		String build = "";
		build += "<AndNode> &&\n";
		
		String print = "";
		print += e1.show() + e2.show();
		
		build += Main.addNewline(print); 
		return build;
	}

	@Override
	public int interpret() {
		if (e1.interpret() == 1 && e2.interpret() == 1) {
			return 1;
		}
		return 0;
	}
};

class GreaterNode implements Expression {
	Expression e1, e2;

	public GreaterNode(Expression e1, Expression e2) {
		super();
		this.e1 = e1;
		this.e2 = e2;
	}

	@Override
	public String show() {
		String build = "";
		build += "<GreaterNode> >\n";
		
		String print = "";
		print += e1.show() + e2.show();
		
		build += Main.addNewline(print); 
		return build;
	}

	@Override
	public int interpret() {
		if (e1.interpret() > e2.interpret()) {
			return 1;
		}
		return 0;
	}
};

class NotNode implements Expression {
	Expression e;
	
	public NotNode(Expression e) {
		super();
		this.e = e;
	}
	
	@Override
	public String show() {
		String build = "";
		build += "<NotNode> !\n";
		
		String print = "";
		print += e.show();
		
		build += Main.addNewline(print); 
		return build;
	}

	@Override
	public int interpret() {
		if (e.interpret() == 0) {
			return 1;
		}
		return 0;
	}
};

class AssignmentNode implements Expression {
	Expression e1, e2;

	public AssignmentNode(Expression e1, Expression e2) {
		super();
		this.e1 = e1;
		this.e2 = e2;
	}

	@Override
	public String show() {
		String build = "";
		build += "<AssignmentNode> =\n";
		
		String print = "";
		print += e1.show() + e2.show();
		
		build += Main.addNewline(print); 
		return build;
	}

	@Override
	public int interpret() {
		if (Main.values.containsKey(((VarNode)e1).var)) {
			Main.values.put(((VarNode)e1).var, e2.interpret());
			System.out.println(((VarNode)e1).var + "=" + e2.interpret());
			return 0;
		}
		return 0;
	}
};

class BlockNode implements Expression {
	Expression e;
	
	public BlockNode(Expression e) {
		super();
		this.e = e;
	}
	
	@Override
	public String show() {
		String build = "";
		build += "<BlockNode> {}\n";
		
		if (e != null) {
			String print = "";
			print += e.show();
			
			build += Main.addNewline(print); 
		}
		return build;
	}

	@Override
	public int interpret() {
		if (e != null) {
			e.interpret();
		}
		return 0;
	}
};

class IfNode implements Expression {
	Expression e;
	BlockNode b1, b2;
	
	public IfNode(Expression e, BlockNode b1, BlockNode b2) {
		super();
		this.e = e;
		this.b1 = b1;
		this.b2 = b2;
	}
	
	@Override
	public String show() {
		String build = "";
		build += "<IfNode> if\n";
		
		String print = "";
		print += e.show() + b1.show() + b2.show();
		
		build += Main.addNewline(print); 
		return build;
	}

	@Override
	public int interpret() {
		if (e.interpret() == 1) {
			return b1.interpret();
		} else {
			return b2.interpret();
		}
	}
	
};

class WhileNode implements Expression {
	Expression e;
	BlockNode b;
	
	public WhileNode(Expression e, BlockNode b) {
		super();
		this.e = e;
		this.b = b;
	}
	
	@Override
	public String show() {
		String build = "";
		build += "<WhileNode> while\n";
		
		String print = "";
		print += e.show() + b.show();
		
		build += Main.addNewline(print); 
		return build;
	}

	@Override
	public int interpret() {
		while (e.interpret() == 1) {
			b.interpret();
		}
		return 0;
	}
	
};

class SequenceNode implements Expression {
	Expression e1, e2;
	
	public SequenceNode(Expression e1, Expression e2) {
		super();
		this.e1 = e1;
		this.e2 = e2;
	}
	
	@Override
	public String show() {
		String build = "";
		build += "<SequenceNode>\n";
		
		String print = "";
		print += e1.show() + e2.show();
		
		build += Main.addNewline(print); 
		return build;
	}

	@Override
	public int interpret() {
		e1.interpret();
		e2.interpret();
		return 0;
	}
	
};