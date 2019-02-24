import java.io.*;
import java.util.*;
 
public class Main {
	
	// Used to keep the values of the variables
	public static HashMap<String, Integer> values = new HashMap<>();
	
	public static String addNewline(String print) {
		Scanner scanner = new Scanner(print);
		String build = "";
		while (scanner.hasNextLine()) {
			String line = scanner.nextLine();
			build += "\t" + line + "\n";
		}
		scanner.close();
		return build;
	}

	public static void main (String[] args) throws IOException {
		TemaLexer l = new TemaLexer(new FileReader("input"));

		l.yylex();
		Expression e = l.stack.pop();
		l.stack.push(e);
		l.stack.push(new MainNode(e));
		
		// Writing AST
		BufferedWriter writer = new BufferedWriter(new FileWriter("arbore"));
	    	writer.write(((Expression) l.stack.pop()).show());
	    	writer.close();
	    
	    	// HashMap initialization
	    	for (String var: l.variables) {
	    		values.put(var, null);
	    	}
	    
	    	// Writing output
	    	BufferedWriter writer2 = new BufferedWriter(new FileWriter("output"));
	    	l.stack.pop().interpret();
    		for (Map.Entry<String, Integer> pair: values.entrySet()) {
	    		writer2.write(pair.getKey() + "=" + pair.getValue() + "\n");
        	}
	    	writer2.close();
	}
	
}
