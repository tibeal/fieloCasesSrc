trigger F_Cases on Case (before insert, after insert, before update, after update){
	if(Trigger.isBefore){
		if(Trigger.isInsert){
			F_Cases.onBeforeInsert(Trigger.new);
		}else if(Trigger.isUpdate){
			F_Cases.onBeforeUpdate(Trigger.new, Trigger.oldMap);
		}
	}
	if(Trigger.isAfter){
		if(Trigger.isInsert){
			F_Cases.onAfterInsert(Trigger.new);
		}else if(Trigger.isUpdate){
			F_Cases.onAfterUpdate(Trigger.new, Trigger.oldMap);
		}
	}
}