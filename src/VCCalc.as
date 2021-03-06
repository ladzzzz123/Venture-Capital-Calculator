// ActionScript file
// @author Kyle Powers, Jason Kruse
import mx.collections.ArrayCollection;
import mx.controls.TextInput;
import mx.formatters.NumberBase;
import mx.core.Application;
import mx.core.WindowedApplication;
import adobe.utils.ProductManager;

private var seriesLetters:Array = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"];
private var curSeries:int = 0; 

private var series:Array = new Array();
//outputs
private var founders:Object = new Object();
[Bindable]private var rounds:Array = new Array();
[Bindable]private var roundsPie:ArrayCollection = new ArrayCollection();
private var atExit:Object = new Object();
private var objColl:ArrayCollection = new ArrayCollection();
private var temp:Object = new Object(); 
private var incManagementPool:Boolean =false;
private var pieCurSeries:int = 0;

private function validatePercent(target:TextInput):void {
	if(Number(target.text) < 0 || Number(target.text) > 1 ) {
		target.text = "";
		Alert.show("Please enter a value between 0 and 1");	
	}
}
private function validatePos(target:TextInput):void {
	if(Number(target.text) < 0) {
		target.text = "";
		Alert.show("Please enter a non-negative number");	
	}
}


private function showGraphs():void {
	currentState='Graphs';
	pieCurSeries = 0;
	piePrev.enabled = false;
	pieNext.enabled = true;
	pieSeriesLabel.text = "Founders";
	roundsPie.removeAll();	
	roundsPie.addItem( { round: 'Founders', sharesIssued: 1000000 });

	
	if(rounds.length == series.length) {
		rounds[rounds.length] = new Object();
		rounds[rounds.length-1].totalInvestment = rounds[rounds.length-2].totalInvestment;
		rounds[rounds.length-1].firmValuation = atExit.firmValuation;
	}
}
private function scrollPie(dir:int):void {
	pieCurSeries += dir;
	trace(pieCurSeries,rounds.length);
	if(dir > 0) {
		// add something to array collection
		piePrev.enabled = true;
		var title:String;
		if(pieCurSeries >= rounds.length) {
			pieNext.enabled = false;
			roundsPie.addItem(new PieChartItem("Exit",atExit.sharesIssued));
		} else {
			roundsPie.addItem(new PieChartItem(title = "Round " + pieCurSeries,rounds[pieCurSeries-1].sharesIssued));
		}
			
	} else {
		// remove last item form array collection
		pieNext.enabled = true;
		if(pieCurSeries == 0) {
			piePrev.enabled = false;
		}
		roundsPie.removeItemAt(roundsPie.length -1);
		
	}
	if(pieCurSeries == 0) {
		pieSeriesLabel.text = "Founders";
	}
	if(pieCurSeries >= rounds.length) {
		pieSeriesLabel.text = "Exit";
	} else {	
		this.pieSeriesLabel.text = "Round " + (pieCurSeries);
	}
	
}
private function debug():void {
	// fill out all text boxes
	toExit.text = "60";
	numRounds.text = "3";
	numFounderShares.text = "1000000";
	PERatio.text = "15";
	earnings.text = "2500000";
	//managementPercent.text = "15";
	//this.incManagementPool = true;
	// fill out series text boxes
	series[0] = {monToInvestment: 0, investmentAmount: 1500000, targetROI: .5 };
	series[1] = {monToInvestment: 24, investmentAmount: 1000000, targetROI: .4 };
	series[2] = {monToInvestment: 48, investmentAmount: 1000000, targetROI: .25 };
	calculate(false);
}
private function openRounds():void {
	if(int(numRounds.text) > 0) {
		if(int(numRounds.text) > 1) {
			nextbtn.enabled = true;
		}
		this.seriesInputParent.height = 140;
	}
	
}
private function toggleManPool(open:Boolean):void {
	if(open) {
		incManagementPool = true;
		this.managementSharesParent.height = 30;
		this.height += 30;
	} else {
		
		this.managementSharesParent.height = 0;
		if(incManagementPool) 
			this.height -= 30;
		incManagementPool = false;
	}
}
private function saveRound():void {
	series[curSeries] = {monToInvestment: int(monToInvestment.text), investmentAmount: int(investmentAmount.text), targetROI:Number(targetROI.text) };
}
private function test():void {
	//trace(series.length, series[curSeries-1].monToInvestment);
	
}
private function validate():Boolean {
	if(toExit.text == "" || numRounds.text == "" || numFounderShares.text == "" || PERatio.text == "" || earnings.text == "") {
		Alert.show("Please fill out all the inputs");
		return false;	
	}
	if(Number(toExit.text) < 0 || Number(numRounds.text) < 1 || Number(numFounderShares.text) < 0 || Number(PERatio.text) < 0 || Number(earnings.text) < 0) {
		Alert.show("There is an error in your inputs. Please try again");
		return false;	
	} 
	
	return true;
}
private function calculate(saveNewRound:Boolean=true):void {
	// validate fields
	if(!validate()) {
		return;
	}	
	 
	
	var x:int;
	var y:int;
	if(saveNewRound)
		saveRound();
	atExit.firmValuation = int(PERatio.text) * int(earnings.text);
	
	trace(series[x].investmentAmount);
	founders.sharesIssued = int(numFounderShares.text);
	founders.sharesOutstanding = int(numFounderShares.text);
	founders.initialOwnership = 100;
	var sharesOutstanding:int;
	var totalVCOwnership:Number = 0;
	var laterInvestment:Number;
	var totalInvestment:int = 0;
	for(x=0;x<series.length;x++) {
		rounds[x] = new Object();
		rounds[x].monToInvestment = series[x].monToInvestment;
		rounds[x].newInvestment = series[x].investmentAmount;
		rounds[x].totalInvestment = totalInvestment + rounds[x].newInvestment;
		totalInvestment += rounds[x].newInvestment;
		rounds[x].yearsToExit = (int(toExit.text) /12) - (series[x].monToInvestment / 12);
		rounds[x].reqROI = Number(series[x].targetROI);
		rounds[x].reqTerminalVal = rounds[x].newInvestment * Math.pow(1 + rounds[x].reqROI,rounds[x].yearsToExit);
		rounds[x].terminalOwnership = rounds[x].reqTerminalVal / atExit.firmValuation;
		totalVCOwnership += rounds[x].terminalOwnership;
	}
	
	// run through again for ownership percentages
	for(x=0;x<series.length;x++) {
		laterInvestment =0;
		for(y=x+1;y<series.length;y++) {
			laterInvestment += rounds[y].terminalOwnership;
		}
		if(this.incManagementPool) {
			laterInvestment += Number(managementPercent.text) / 100;
		}
		rounds[x].retention = 1 - laterInvestment;
		rounds[x].initialOwnership = rounds[x].terminalOwnership / rounds[x].retention;
		
		if(x==0) {
			sharesOutstanding = founders.sharesOutstanding;
			//mx.controls.Alert.show(rounds[x].initialOwnership + " | " + sharesOutstanding); 	
		} else {
			sharesOutstanding = rounds[x-1].sharesOutstanding;
		}
		
		rounds[x].sharesIssued = (rounds[x].initialOwnership * sharesOutstanding) / ( 1 - rounds[x].initialOwnership);
		rounds[x].sharesOutstanding = sharesOutstanding + rounds[x].sharesIssued;
		rounds[x].sharePrice = rounds[x].newInvestment / rounds[x].sharesIssued;
		rounds[x].firmValuation = rounds[x].sharesOutstanding * rounds[x].sharePrice;
		  		
		if(x==0) {
			// first run through, figure out some more founders info now that we have an initial investment
			founders.sharePrice = rounds[0].sharePrice;
			founders.firmValuation = founders.sharesOutstanding * founders.sharePrice; 	
		}
	}
	sharesOutstanding += rounds[series.length-1].sharesIssued
	if(this.incManagementPool) {
		totalVCOwnership += Number(managementPercent.text) / 100;
		atExit.retention = 1;
		atExit.initialOwnership = Number(managementPercent.text) / 100;
		atExit.sharesIssued = (atExit.initialOwnership * sharesOutstanding) / ( 1 - atExit.initialOwnership);;
		//Alert.show(sharesOutstanding + " | " + atExit.sharesIssued);
		atExit.sharesOutstanding = sharesOutstanding + atExit.sharesIssued;
	} else {
		atExit.retention = "";
		atExit.initialOwnership = "";
		atExit.sharesIssued = "";
		atExit.sharesOutstanding = sharesOutstanding;
	}
	
	
	atExit.sharePrice = atExit.firmValuation / atExit.sharesOutstanding;
	if(this.incManagementPool) {
		atExit.valueAtExit = atExit.sharesIssued * atExit.sharePrice;
	} else {
		atExit.valueAtExit = "";
	}
	founders.terminalOwnership = Number(1 - totalVCOwnership);
	for(y=0;y<series.length;y++) {
		rounds[y].valueAtExit = rounds[y].sharesIssued * atExit.sharePrice;
		trace(y + ")" + rounds[y].valueAtExit);
	}
	
	founders.valueAtExit = founders.sharesIssued * atExit.sharePrice;
	
	currentState='Output';
	fillGrid();
}

private function fillGrid():void{
	var str:String; 
	var i:int;
	var base:NumberBase = new NumberBase();
//begin: add headings
	addDataGridColumn("col0", "Founders");
	this.validateNow();
	for(var x:int=1;x<= int(numRounds.text); x++){
		addDataGridColumn("col" + x, "Round " + x);
		this.validateNow();
	}
	addDataGridColumn("col" + (output_table.columns.length + 1), "Exit");
	this.validateNow();
//end: add headings

//years from initiation
	for(i=1;i<output_table.columns.length - 1; i++) {
		temp[String("col"+i)] = base.formatPrecision(String((int(toExit.text)/12) - rounds[i-1].yearsToExit),1);
	}
	temp[String("col"+ (output_table.columns.length))] = base.formatPrecision(String(rounds[0].yearsToExit),1);
	addRow();
//years to exit
	for(i=1;i<output_table.columns.length - 1; i++) {
		temp[String("col"+i)] = base.formatPrecision(String(rounds[i-1].yearsToExit),1);
	}
	temp[String("col"+ (output_table.columns.length))] = base.formatPrecision(String(((int(toExit.text)/12) - rounds[0].yearsToExit)),1);
	addRow();
//vc's required ROI
	for(i=1;i<output_table.columns.length - 1; i++) {
		temp[String("col"+i)] = base.formatPrecision(String(100*(Number(String(rounds[i-1].reqROI)))),3) + "%";
	}
	addRow();
//new vc investment
	for(i=1;i<output_table.columns.length - 1; i++) {
		temp[String("col"+i)] = "$" + base.formatThousands(String(Math.round(rounds[i-1].newInvestment)));
	}
	addRow();
//vc's required terminal value
	for(i=1;i<output_table.columns.length - 1; i++) {
		temp[String("col"+i)] = "$" + base.formatThousands(String(Math.round(rounds[i-1].reqTerminalVal)));
	}
	addRow();
//terminal % ownership
	temp[String("col0")] = base.formatPrecision(String(100*(Number(founders.terminalOwnership))),3) + "%";
	for(i=1;i<output_table.columns.length - 1; i++) {
		temp[String("col"+i)] = base.formatPrecision(String(100*(Number(rounds[i-1].terminalOwnership))),3) + "%";
	}
	temp[String("col"+ (output_table.columns.length))] = base.formatPrecision(String(100*(Number(managementPercent.text)/100)),3) + "%";
	addRow();
//retention %
	temp[String("col0")] = base.formatPrecision(String(100*(Number(String(founders.terminalOwnership)))),3) + "%";
	for(i=1;i<output_table.columns.length - 1; i++) {
		temp[String("col"+i)] = base.formatPrecision(String(100*(Number(String(rounds[i-1].retention)))),3) + "%";
	}
	//mx.controls.Alert.show(atExit.retention);
	temp[String("col"+ (output_table.columns.length))] = base.formatPrecision(String(100*(Number(String(atExit.retention)))),3) + "%";
	addRow();
//initial % ownership
	temp[String("col0")] = "100%";
	for(i=1;i<output_table.columns.length - 1; i++) {
		temp[String("col"+i)] = base.formatPrecision(String(100*(Number(String(rounds[i-1].initialOwnership)))),3) + "%";
	}
	temp[String("col"+ (output_table.columns.length))] = base.formatPrecision(String(100*(Number(String(atExit.initialOwnership)))),3) + "%";
	addRow();
//shares issued
	temp[String("col0")] = base.formatThousands(String(Math.round(int(numFounderShares.text))));
	for(i=1;i<output_table.columns.length - 1; i++) {
		temp[String("col"+i)] = base.formatThousands(String(Math.round(rounds[i-1].sharesIssued)));
	}
	temp[String("col"+ (output_table.columns.length))] = base.formatThousands(String(Math.round(atExit.sharesIssued)));
	addRow();
//shares outstanding
	temp[String("col0")] = base.formatThousands(String(Math.round(founders.sharesOutstanding)));
	for(i=1;i<output_table.columns.length - 1; i++) {
		temp[String("col"+i)] = base.formatThousands(String(Math.round(rounds[i-1].sharesOutstanding)));
	}
	temp[String("col"+ (output_table.columns.length))] = base.formatThousands(String(Math.round(atExit.sharesOutstanding)));
	addRow();
//share price
	temp[String("col0")] = "$" + base.formatPrecision(String(founders.sharePrice),3);
	for(i=1;i<output_table.columns.length - 1; i++) {
		temp[String("col"+i)] = "$" + base.formatPrecision(String(rounds[i-1].sharePrice),3);
	}
	temp[String("col"+ (output_table.columns.length))] = "$" + base.formatPrecision(String(atExit.sharePrice),3);
	addRow();
//firm valuation
	temp[String("col0")] = "$" + base.formatThousands(String(Math.round(founders.firmValuation)));
	for(i=1;i<output_table.columns.length - 1; i++) {
		temp[String("col"+i)] = "$" + base.formatThousands(String(Math.round(rounds[i-1].firmValuation)));
	}
	temp[String("col"+ (output_table.columns.length))] = "$" + base.formatThousands(String(Math.round(atExit.firmValuation)));
	addRow();
//investment value at exit
	temp[String("col0")] = "$" + base.formatThousands(String(Math.round(founders.valueAtExit)));
	for(i=1;i<output_table.columns.length - 1; i++) {
		temp[String("col"+i)] = "$" + base.formatThousands(String(Math.round(rounds[i-1].valueAtExit)));
	}
	temp[String("col"+ (output_table.columns.length))] = "$" + base.formatThousands(String(Math.round(atExit.valueAtExit)));
	addRow();
}

private function addRow():void {
	arrCol.addItem(temp);
	temp=[];
}

private function switchRound(dir:int):void {
	saveRound();
	
	if(dir > 0) {
		curSeries++;
		monToInvestment.text = "";
		investmentAmount.text = "";
		targetROI.text = "";	
	} else {
		curSeries--;
	}
	if(curSeries == 0) {
		prevbtn.enabled = false;
	} else {
		prevbtn.enabled = true;
	}
	if(curSeries < (int(numRounds.text)-1) ) {
		nextbtn.enabled = true;
	} else {
		nextbtn.enabled = false;
	}
	try {
		monToInvestment.text = series[curSeries].monToInvestment;
		investmentAmount.text = series[curSeries].investmentAmount;
		targetROI.text = series[curSeries].targetROI;
	} catch(e:Error) {
		
	}
	
	serieslbl.text = "Round " + (curSeries+1);
}


private function addDataGridColumn(dataField:String, header:String):void {
    var dgc:AdvancedDataGridColumn = new AdvancedDataGridColumn(dataField);
    dgc.visible = true;
    dgc.headerText = header;
    var cols:Array = output_table.columns;
    cols.push(dgc);
    output_table.columns = cols;
}

public function restart():void
{
   var app:WindowedApplication = WindowedApplication(Application.application);
   var mgr:ProductManager = new ProductManager("airappinstaller");
   mgr.launch("-launch " + app.nativeApplication.applicationID + " " + app.nativeApplication.publisherID);
   app.close();
}