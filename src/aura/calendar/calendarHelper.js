({
	doInit : function(helper,component) {
		var me = this;
		helper.getParentCampaigns(component);
		helper.describeFieldSet("MarketingCalendarPopup",component,function(r){
			component.set('v.MarketingCalendarPopupFields',r.getReturnValue());
			helper.load(helper,component,"","");
			$('.forceInputPicklist select').removeAttr('disabled');
			$('select').select2({width: 'resolve'}).on('change',function(){
				helper.load(helper,component,$('#parentCampaign').val(),$('.forceInputPicklist select').val());
			});
		});
	},
	load : function(helper,component,parentCampaignId,type){
		helper.fetchCalendarData(helper,component,parentCampaignId,type,function(response){
			if (response.getState() === "SUCCESS") {
				//component.set('v.campaigns',response.getReturnValue());
				helper.initCalendar(helper,helper.parseEnteries(response.getReturnValue()));
			}
			else{
				var error = helper.parseErrors(response.getError());
				component.set("v.errors",error);
			}
		})
	},
	fetchCalendarData : function(helper,component,parentCampaignId,type,cb){
		parentCampaignId = (parentCampaignId == '--None--' ? '' : parentCampaignId);
		type = (type == '--None--' ? '' : type);
		var action = component.get("c.getCalendarEntryAura");
		action.setParams({"parentCampaignId":parentCampaignId,"type" : type});
		action.setCallback(helper,cb);
		$A.enqueueAction(action);
	},
	describeFieldSet : function(fs,component,cb){
		var action = component.get("c.describeFieldSet");
		action.setParams({"fieldset":fs});
		action.setCallback(this,cb);
		$A.enqueueAction(action);
	},
	parseCampaigns : function(campaigns){
		var enteries = [];
		for(var i =0 ;i < campaigns.length; i++){
			enteries.push({
				title : campaigns[i].Name,
				start : campaigns[i].StartDate,
				end : campaigns[i].EndDate
			});
		}
		return enteries;
	},
	parseEnteries : function(results){
		for(var i =0 ;i < results.length; i++){
			results[i].start = new Date(results[i].startDate);
			results[i].end = new Date(results[i].endDate);
		}
		return results;
	},
	initCalendar : function(helper,calendarEntries){
		console.log(calendarEntries);
		$('#calendarX').fullCalendar('destroy');
		$('#calendarX').fullCalendar({
			editable: false,
			events: calendarEntries,
			eventClick: function(event) {
				if (event.url) {
					window.open(event.url);
					return false;
				}
			},
			eventRender: function(event, element, view){
				element.qtip({
					position: {
						my: 'top left',
						at: 'bottom center'
					},
					style: {
						width: 300,
						color: 'black',
						name: 'light'
					},
					content: $.templates(helper.decodeEntities($("#qtipTemplate").html())).render(event.campaign)
				});
			}
		});
	},
	toast : function(title,message){
		var toastEvent = $A.get("e.force:showToast");
		if(toastEvent){
			toastEvent.setParams({
			    "title": title,
			    "message": message
			});

			toastEvent.fire();
		}
	},
	parseErrors : function(errorObj){
		console.log('error',errorObj);
		var error = [];
		for(var i = 0; i < errorObj.length > 0; i ++){
			if(errorObj[i].pageErrors){
				error = error.concat(errorObj[i].pageErrors);
			}

			if(errorObj[i].fieldErrors){
				for(f in errorObj[i].fieldErrors){
					error = errorObj[i].fieldErrors[f].concat(errorObj[i].pageErrors);
				}
			}
		}
		return error;
	},
	decodeEntities : function(input) {
	  var y = document.createElement('textarea');
	  y.innerHTML = input;
	  return y.value;
  },
  getParentCampaigns : function(component){
	  var action = component.get("c.getActiveParentCampaignObjects");
	  action.setParams({});
	  action.setCallback(this,function(response){
		  component.set("v.parentCampaigns",response.getReturnValue());
	  });
	  $A.enqueueAction(action);
  }
})
