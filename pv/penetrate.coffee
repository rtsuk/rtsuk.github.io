lineChartData = {
	labels : [1..20],
	datasets : [
		{
			fillColor : "rgba(220,220,220,0.5)",
			strokeColor : "rgba(220,220,220,1)",
			pointColor : "rgba(220,220,220,1)",
			pointStrokeColor : "#fff",
			data : []
		},
		{
			fillColor : "rgba(151,187,205,0.5)",
			strokeColor : "rgba(151,187,205,1)",
			pointColor : "rgba(151,187,205,1)",
			pointStrokeColor : "#fff",
			data : []
		}
	]
	
}

showChart = () ->
	myLine = new Chart(document.getElementById("penetrationChart").getContext("2d")).Line(lineChartData, scaleOverride: true, scaleSteps: 10, scaleStepWidth: 10, scaleStartValue: 0);

randomInt = (lower, upper) ->
  return Math.floor(Math.random() * (upper - lower) + lower)

roll = (sides) ->
	randomInt(1, sides)
	
getIntSelectValue = (inputName) ->
	parseInt $("select[name='#{inputName}']").val(), 10

getIntValue = (inputName) ->
	parseInt $("input[name='#{inputName}']").val(), 10

getBooleanValue = (inputName) ->
	$("input[name='#{inputName}']").is(':checked')
	
calculateOne = (attackDice, crits, hits, defenseDice, shields, firepower, armor, cancelCrits) ->
	critCount = 0
	hitCount = 0
	penetrate = false
	for i in [0..attackDice] by 1
		attackRoll = roll 6
		if 1 <= attackRoll <= crits
			critCount += 1
		else if attackRoll <= (crits + hits)
			hitCount += 1
	
	for i in [0..defenseDice] by 1
		defenseRoll = roll 6
		if defenseRoll <= shields
			if cancelCrits
				if critCount > 0
					critCount -= 1
				else if hitCount > 0
					hitCount -= 1
			else
				if hitCount > 0
					hitCount -= 1
				else if critCount > 0
					critCount -= 1
	
	if critCount > 0
		result = firepower + critCount + hitCount
		if result > armor
			penetrate = true
				
	hit: hitCount > 0 || critCount > 0, penetrate: penetrate
	
calculate = () ->
	iterations = getIntValue "iterations"
	attackDice = getIntValue "attackDice"
	defenseDice = getIntValue "defenseDice"
	firepower = getIntValue "firepower"
	hitSides = getIntValue "hitSides"
	critSides = getIntValue "critSides"
	shields = getIntValue "shieldSides"
	range = getIntSelectValue "range"
	switch range
		when 1
			attackDice += 1
		when 3
			defenseDice += 1
		when 4
			defenseDice += 2
	
	$("#details").text "#{attackDice} attack dice vs #{defenseDice} defense dice"
	cancelCritsFirst = getBooleanValue "cancelCrits"
	for armor in [1...20]
		hitCount = 0
		penetrateCount = 0
		for i in [1..iterations] by 1
			{hit, penetrate} = calculateOne attackDice, hitSides, critSides, defenseDice, shields, firepower, armor, cancelCritsFirst
			if hit
				hitCount += 1
			if penetrate
				penetrateCount += 1
				
		lineChartData.datasets[0].data[armor-1] = hitCount / iterations * 100 
		lineChartData.datasets[1].data[armor-1] = penetrateCount / iterations * 100
	return
	
$ () ->
	showChart()
	
	$('#penetrationForm').submit () ->
		calculate()
		showChart()
		false
