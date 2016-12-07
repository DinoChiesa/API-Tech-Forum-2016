// formatJsonFault.js
// ------------------------------------------------------------------
//
// created: Mon Dec  5 21:41:17 2016
// last saved: <2016-December-05 22:31:01>

var fault = JSON.parse(context.getVariable('message.content')).fault;
var re1 = new RegExp('.*JSONThreatProtection\\[.+\\]: *(.+)$');
var match = re1.exec(fault.faultstring);
if (match && match[1]) {
  context.setVariable('regexp_match', match[1]);
  var payload = {
        "error" : {
          "type" : "json",
          "cause" : match[1]
        }
      };
  context.setVariable('message.content', JSON.stringify(payload, null, 2));
  context.setVariable('message.status.code', 400);
}
