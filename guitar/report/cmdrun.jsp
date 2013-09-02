<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<% //form 으로부터 온 파라미터 값 처리
  String cmd = request.getParameter("cmd");
  String scriptselect = request.getParameter("scriptselect");
  String script_c = request.getParameter("script_c");
  String encoding = request.getParameter("encoding");
  String script_x ="";
  String captureview ="xx";

  script_c=(script_c == null) ? "" : script_c;
  encoding=(encoding == null) ? "" : encoding;
  scriptselect=(scriptselect == null) ? "" : scriptselect;


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
      		Runtime.getRuntime().exec((application.getRealPath("./" + "GUITARCmdSender.exe") + " " + cmd + " " + script_c));
  		}catch(Exception e){ }

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


<body>
<form name="frm" action="remote.jsp" method="post">
<input type="hidden" name="captureview" value="<%= captureview%>">
</form>
<script language="javascript">
frm.submit();
</script>

</body>
</html>
