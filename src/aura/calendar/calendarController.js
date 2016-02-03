({
	doInit : function(component, event, helper) {
		helper.doInit(helper,component);
	},
	reload :function(component, event, helper){
		console.log('reloading');
		helper.load(component,helper);
	}
})
