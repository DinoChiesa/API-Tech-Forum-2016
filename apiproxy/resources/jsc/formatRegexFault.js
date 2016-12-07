// formatRegexFault.js
// ------------------------------------------------------------------
//
// created: Mon Dec  5 21:41:17 2016
// last saved: <2016-December-05 22:30:52>

var fault = JSON.parse(context.getVariable('message.content')).fault;
var re1 = new RegExp('.*Regular Expression Threat Detected.+ regex: (.+) input: (.+)$');
var match = re1.exec(fault.faultstring);
if (match && match[1]) {
  var payload = {
        "error" : {
          "type" : "regex",
          "pattern" : match[1],
          "input" : match[2]
        }
      };
  context.setVariable('message.content', JSON.stringify(payload, null, 2));
  context.setVariable('message.status.code', 400);
}
