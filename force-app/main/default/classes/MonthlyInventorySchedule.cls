public class MonthlyInventorySchedule implements Schedulable {
    
    public void execute(SchedulableContext SC){
        ProductInventoryBatch batch = new ProductInventoryBatch();
        Database.executeBatch(batch);
	}

}

/*ProductInventoryBatch batch = new ProductInventoryBatch();
String cron = '0 0 0 1 * ?';
system.schedule('Inventory batch', cron, batch);*/

//Immediate to test
/*MonthlyInventorySchedule mis = new MonthlyInventorySchedule();
mis.execute(null);*/