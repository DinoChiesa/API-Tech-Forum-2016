// formatSpikeFault.js
// ------------------------------------------------------------------
//
// created: Mon Dec  5 21:41:17 2016
// last saved: <2016-December-05 22:46:28>

var fault = JSON.parse(context.getVariable('message.content')).fault;
var re1 = new RegExp('.*Spike arrest violation *(.+)$');
var match = re1.exec(fault.faultstring);
if (match && match[1]) {
  context.setVariable('regexp_match', match[1]);
  var payload = {
        "error" : {
          "type" : "spike",
          "cause" : match[0]
        }
      };
  context.setVariable('message.content', JSON.stringify(payload, null, 2));
  context.setVariable('message.status.code', 429);
}
