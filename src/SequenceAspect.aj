import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.LinkedList;

import org.apache.commons.lang3.StringUtils;
import org.aspectj.lang.Signature;

import net.sourceforge.plantuml.FileFormat;
import net.sourceforge.plantuml.FileFormatOption;
import net.sourceforge.plantuml.SourceStringReader;


/**
 * 
 */

/**
 * @author Meenakshi
 *
 */
public aspect SequenceAspect {

	String main = "";
	LinkedList<String[]> messages = new LinkedList<String[]>();
	LinkedList<String> umlMessages = new LinkedList<String>();

	pointcut mainPointCut() : execution(public static void main(..)) && !within(SequenceAspect);

	pointcut methodPointCut() : call(* *.*(..)) && !within(SequenceAspect) && !call(* java..*.*(..)) && !cflow(execution(*.new(..)));


	before() : mainPointCut() {
		main = thisJoinPoint.getSourceLocation().getWithinType().getName();
	}

	before() : methodPointCut() {
		String source = "";
		String target = ""; 
		// Get Source class
		if (thisJoinPoint.getThis() != null)
			source = thisJoinPoint.getThis().getClass().getName();
		else
			source = main;
		// Get Target Class
		if (thisJoinPoint.getTarget() != null)
			target = thisJoinPoint.getTarget().getClass().getName();
		else
			target = main;
		// Get message structure
		Signature methodSign = thisJoinPoint.getSignature();
		String returnType = methodSign.toString().split(" ")[0];
		String parameters =  StringUtils.substringBetween(methodSign.toLongString(), "(", ")");
		String methodName = methodSign.getName();
		String message = methodName + ((parameters != null) ? "(" + parameters + ")" : "") + " : " + returnType;
		messages.add(new String[]{source , target, message});
	}


	after() : mainPointCut() {
		// Generate UML String
		getUMLMessages();
		StringBuilder builder = new StringBuilder("@startuml\n");
		for(String umlMessage : umlMessages){
			builder.append(umlMessage + "\n");
		}
		builder.append("\n@enduml");
		// Generate sequence diagram as image
		try {
			FileOutputStream fileOutputStream = new FileOutputStream("sequence.png");
			SourceStringReader sourceStringReader = new SourceStringReader(builder.toString());
			sourceStringReader.generateImage(fileOutputStream, new FileFormatOption(FileFormat.PNG));
			fileOutputStream.close();
		} catch( FileNotFoundException e)  {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} 


	}

	public void getUMLMessages(){

		for(String[] message : messages){
			String source = message[0];
			String target = message[1];
			String messageString = message[2];
			String messageStr = source + "->" + target + " : " + messageString;
			umlMessages.add(messageStr); 
		}
	}




}
