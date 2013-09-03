<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<% //form 으로부터 온 파라미터 값 처리
  String cmd = request.getParameter("cmd");
  String scriptselect = request.getParameter("scriptselect");
  String script_c = request.getParameter("script_c");
  String encoding = request.getParameter("encoding");
  String testid = request.getParameter("testid");
  String xmlpath = request.getParameter("xmlpath");
  String script_x ="";
  String captureview ="xx";
  String returnCode="";
  int exitCode;

  script_c=(script_c == null) ? "" : script_c;
  encoding=(encoding == null) ? "" : encoding;
  testid=(testid == null) ? "" : testid;
  xmlpath=(xmlpath == null) ? "" : xmlpath;

  scriptselect=(scriptselect == null) ? "" : scriptselect;

  if (testid != "") {
	testid  = "/TESTID:" + testid;
  }


  if (xmlpath != "") {
	xmlpath  = "/XMLPATH:" + xmlpath;
  }


  if (scriptselect.equals("c")) {
	  script_c = new String(script_c.getBytes("8859_1"),"UTF-8");

  }

  else {
	if (scriptselect.equals("m") || encoding.equals("utf8")) {
		script_c = new String(request.getParameter("script").getBytes("8859_1"),"UTF-8");

	}
	else {
		script_c = new String(request.getParameter("script").getBytes("8859_1"),"euc-kr");

	}
  }

  if(cmd.equals("capture") || cmd.equals("stop") || cmd.equals("end") || cmd.equals("run") )

  {
	  try{
      		Process process = Runtime.getRuntime().exec((application.getRealPath("./" + "GUITARCmdSender.exe") + " " + cmd + " " + script_c + " " + testid + " " + xmlpath));

			process.waitFor();

			exitCode = process.exitValue();

			if(exitCode == 0) {
				returnCode="SUCCESS";
			} else {
				returnCode="FAIL";
			}

  		}catch(Exception e){}

  	  try{Thread.sleep(3000);}catch(Exception e){}

  	  if (cmd.equals("capture")){
  		captureview="on";
  	  }
  		else {
  		captureview="off";
  	  }
  }

%>




<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<script language="javascript">

function getCookie(name){
    var nameOfCookie = name + "=";
    var x = 0;
    while ( x <= document.cookie.length ){
        var y = (x+nameOfCookie.length);
        if ( document.cookie.substring( x, y ) == nameOfCookie ) {
            if ( (endOfCookie=document.cookie.indexOf( ";", y )) == -1 ) {
                endOfCookie = document.cookie.length;
            }
            return unescape( document.cookie.substring( y, endOfCookie ) );
        }
        x = document.cookie.indexOf( " ", x ) + 1;
        if ( x == 0 )
        break;
    }
    return "";
}



function setCookie (name, value) {
  var argv = setCookie.arguments;
  var argc = setCookie.arguments.length;
  var expires = (2 < argc) ? argv[2] : null;
  var path = (3 < argc) ? argv[3] : null;
  var domain = (4 < argc) ? argv[4] : null;
  var secure = (5 < argc) ? argv[5] : false;
  document.cookie　 = name + "=" + escape (value) +
      ((expires == null) ? "" :
        ("; expires=" + expires.toGMTString())) +
      ((path == null) ? "" : ("; path=" + path)) +
      ((domain == null) ? "" : ("; domain=" + domain)) +
      ((secure == true) ? "; secure" : "");
}

</script>

<script language="JavaScript">
	function forwarding()
	{frm.submit();}
</script>

<body onLoad="setTimeout('forwarding()', 10)">

<%=cmd%>:<%=returnCode%>
<form name="frm" action="remote.jsp" method="post">
<input type="hidden" name="captureview" value="<%= captureview%>">
</form>
</body>
</html>

