--[[
    Status screen display

    This code goes into unit -> start() filter of the programming board

    Make sure you name your screen slot: displayT1, displayT2, displayT3, displayT4, displayT5
    Make sure to link the core, and rename the slot core.
    Make sure to add a tick filter to unit slot, name the tick: updateTable
    In tick lua code, add: generateHtml()
    Add stop filter with lua code, add: displayOff()
    If you don't have a tier of containers, leave off the corresponding display.
    Container Mass, and Volume are now autocalculated, ecxept for hubs.
    Enter your Hub Volume, Container Proficiency % and Container Optimization % (without the -) in advanced > lua parameters.
    Containers should be named such as Pure Aluminum and Bauxite Ore to be properly indexed.
    If you use Container Hubs, name the hub, don't name the containers, as that will cause issues.
]]

unit.hide()
if displayT1 then displayT1.activate() end
if displayT2 then displayT2.activate() end
if displayT3 then displayT3.activate() end
if displayT4 then displayT4.activate() end
if displayT5 then displayT5.activate() end

function displayOff()
    if displayT1 then displayT1.clear() end
    if displayT2 then displayT2.clear() end
    if displayT3 then displayT3.clear() end
    if displayT4 then displayT4.clear() end
    if displayT5 then displayT5.clear() end
end

function generateHtml()

    elementsIds = core.getElementIdList()
    containers = {}
    data = {}

    function newContainer(_id)
        local container = 
        {
            id = _id;
            name = core.getElementNameById(_id);
            mass = core.getElementMassById(_id);
            maxHp = core.getElementMaxHitPointsById(_id);
        }
        return container
    end


    for i = 1, #elementsIds do
        if string.match(core.getElementTypeById(elementsIds[i]), "ontainer") and string.match(core.getElementNameById(elementsIds[i]),"Ore") then
            table.insert(containers, newContainer(elementsIds[i]))
        end
    end

    for i = 1, #containers do
        table.insert(data, {Container = containers[i].name, ContainerMass = containers[i].mass, maxHp = containers[i].maxHp})
    end

    function round(number,decimals)
        local power = 10^decimals
        return math.floor((number/1000) * power) / power
    end 

    function ContainerMaxVol(hp)
        if hp > 49 and hp <=123 then vol = hub
        elseif hp > 123 and hp <= 998 then vol = (1000+(1000*(containerProficiency/100)))
        elseif hp > 998 and hp <= 7996 then vol = (8000+(8000*(containerProficiency/100)))
        elseif hp > 7996 and hp <= 17315 then vol = (64000+(64000*(containerProficiency/100)))
        elseif hp > 17315 then vol = (128000+(128000*(containerProficiency/100)))
        end
        return vol
    end

    function ContainerSelfMass(hp)
        if hp > 49 and hp <=123 then sm = 0
        elseif hp > 123 and hp <= 998 then sm = 229.09
        elseif hp > 998 and hp <= 7996 then sm = 1280
        elseif hp > 7996 and hp <= 17315 then sm = 7420
        elseif hp > 17315 then sm = 14840
        end
        return sm
    end

    function OptimizedContainerMass(mass)
        oMass = (mass+(mass*(containerOptimization/100)))
        return oMass
    end

    function Status(percent)
        if percent <= 0 then return "<th style=\"color: red;\">EMPTY</th>"
        elseif percent > 0 and percent <=25 then return "<th style=\"color: red;\">LOW</th>"
        elseif percent > 25 and percent <= 50 then return "<th style=\"color: orange;\">LOW</th>"
        elseif percent > 50 and percent <= 99 then return "<th style=\"color: green;\">GOOD</th>"
        else return "<th style=\"color: green;\">FULL</th>"
        end 
    end

    function BarGraph(percent)
        if percent <= 0 then barcolour = "red"
        elseif percent > 0 and percent <=25 then barcolour = "red"
        elseif percent > 25 and percent <= 50 then barcolour = "orange"
        elseif percent > 50 and percent <= 99 then  barcolour = "green"
        else  barcolour = "green"
        end 
        return "<td class=\"bar\" > <svg ><rect x=\"0\" y=\"5\" height=\"30\" width=\"140\" stroke=\"white\" stroke-width=\"1\"  rx=\"4\" /><rect x=\"0\" y=\"5\" height=\"30\" width=\"" .. percent * 1.4 .. "\"  fill=\"" .. barcolour .. "\" opacity=\"0.8\" rx=\"2\"/><text x=\"5\" y=\"30\" fill=\"white\" text-align=\"center\" margin-left=\"5\">" .. percent .. "%</text> </svg></td>"        
    end

    hub = 166400 --export: This is the total volume of your hub, at present, all hubs need to be the same
    containerProficiency = 30 --export: This is the % voume increase of your Container Proficiency talent
    containerOptimization = 0 --export: This is the % mass decrease of your Container Optimization talent
    local Error = "<th style=\"color: red;\">ERROR</th>"

--T1 Stuff
    -- Bauxite Variables 
    for k, v in pairs(data) do
        if string.match(data[k].Container,"Bauxite") then
            local weight = 1.28
            massBauxiteOre = round(math.ceil((OptimizedContainerMass(data[k].ContainerMass) - ContainerSelfMass(data[k].maxHp)) / weight),1)
            percentBauxiteOre = math.ceil(((math.ceil((massBauxiteOre*1000) - 0.5)/(ContainerMaxVol(data[k].maxHp)))*100))
            statusBauxiteOre = Status(percentBauxiteOre)
            maxVolBauxiteOre = (ContainerMaxVol(data[k].maxHp))/1000
        end
    end
    if massBauxiteOre == nil then
        massBauxiteOre = 0
        percentBauxite = 0
        statusBauxiteOre = Error
        maxVolBauxiteOre = 0
    end

    -- CoalOre Variables
    for k, v in pairs(data) do
        if string.match(data[k].Container,"Coal") then
            local weight = 1.35
            massCoalOre = round(math.ceil((OptimizedContainerMass(data[k].ContainerMass) - ContainerSelfMass(data[k].maxHp)) / weight),1)
            percentCoalOre = math.ceil(((math.ceil((massCoalOre*1000) - 0.5)/(ContainerMaxVol(data[k].maxHp)))*100))
            statusCoalOre = Status(percentCoalOre)
            maxVolCoalOre = (ContainerMaxVol(data[k].maxHp))/1000
        end
    end
    if massCoalOre == nil then
        massCoalOre = 0
        percentCoalOre = 0
        statusCoalOre = Error
        maxVolCoalOre = 0
    end

    -- HematiteOre Variables
    for k, v in pairs(data) do
        if string.match(data[k].Container,"Hematite") then
            local weight = 5.04
            massHematiteOre = round(math.ceil((OptimizedContainerMass(data[k].ContainerMass) - ContainerSelfMass(data[k].maxHp)) / weight),1)
            percentHematiteOre = math.ceil(((math.ceil((massHematiteOre*1000) - 0.5)/(ContainerMaxVol(data[k].maxHp)))*100))
            statusHematiteOre = Status(percentHematiteOre)
            maxVolHematiteOre = (ContainerMaxVol(data[k].maxHp))/1000
        end
    end
    if massHematiteOre == nil then
        massHematiteOre = 0
        percentHematiteOre = 0
        statusHematiteOre = Error
        maxVolHematiteOre = 0
    end

    -- QuartzOre Variables
    for k, v in pairs(data) do
        if string.match(data[k].Container, "Quartz") then
            local weight = 2.65
            massQuartzOre = round(math.ceil((OptimizedContainerMass(data[k].ContainerMass) - ContainerSelfMass(data[k].maxHp)) / weight),1)
            percentQuartzOre = math.ceil(((math.ceil((massQuartzOre*1000) - 0.5)/(ContainerMaxVol(data[k].maxHp)))*100))
            statusQuartzOre = Status(percentQuartzOre)
            maxVolQuartzOre = (ContainerMaxVol(data[k].maxHp))/1000
        end
    end
    if massQuartzOre == nil then
        massQuartzOre= 0
        percentQuartzOre = 0
        statusQuartzOre = Error
        maxVolQuartzOre = 0
    end

--T2 Stuff

    -- ChromiteOre Variables 
    for k, v in pairs(data) do
        if string.match(data[k].Container, "Chromite") then
            local weight = 4.54
            massChromiteOre = round(math.ceil((OptimizedContainerMass(data[k].ContainerMass) - ContainerSelfMass(data[k].maxHp)) / weight),1)
            percentChromiteOre = math.ceil(((math.ceil((massChromiteOre*1000) - 0.5)/(ContainerMaxVol(data[k].maxHp)))*100))
            statusChromiteOre = Status(percentChromiteOre)
            maxVolChromiteOre = (ContainerMaxVol(data[k].maxHp))/1000
        end
    end
    if massChromiteOre == nil then
        massChromiteOre = 0
        percentChromiteOre = 0
        statusChromiteOre = Error
        maxVolChromiteOre = 0
    end

    -- MalachiteOre Variables 
    for k, v in pairs(data) do
        if string.match(data[k].Container, "Malachite") then
            local weight = 4.00
            massMalachiteOre = round(math.ceil((OptimizedContainerMass(data[k].ContainerMass) - ContainerSelfMass(data[k].maxHp)) / weight),1)
            percentMalachiteOre = math.ceil(((math.ceil((massMalachiteOre*1000) - 0.5)/(ContainerMaxVol(data[k].maxHp)))*100))
            statusMalachiteOre = Status(percentMalachiteOre)
            maxVolMalachiteOre = (ContainerMaxVol(data[k].maxHp))/1000
        end
    end
    if massMalachiteOre == nil then
        massMalachiteOre = 0
        percentMalachiteOre = 0
        statusMalachiteOre = Error
        maxVolMalachiteOre = 0
    end

    -- LimestoneOre Variables 
    for k, v in pairs(data) do
        if string.match(data[k].Container, "Limestone") then
            local weight = 2.71
            massLimestoneOre = round(math.ceil((OptimizedContainerMass(data[k].ContainerMass) - ContainerSelfMass(data[k].maxHp)) / weight),1)
            percentLimestoneOre = math.ceil(((math.ceil((massLimestoneOre*1000) - 0.5)/(ContainerMaxVol(data[k].maxHp)))*100))
            statusLimestoneOre = Status(percentLimestoneOre)
            maxVolLimestoneOre = (ContainerMaxVol(data[k].maxHp))/1000
        end
    end
    if massLimestoneOre == nil then
        massLimestoneOre = 0
        percentLimestoneOre = 0
        statusLimestoneOre = Error
        maxVolLimestoneOre = 0
    end

    -- NatronOre Variables 
    for k, v in pairs(data) do
        if string.match(data[k].Container, "Natron") then
            local weight = 1.55
            massNatronOre = round(math.ceil((OptimizedContainerMass(data[k].ContainerMass) - ContainerSelfMass(data[k].maxHp)) / weight),1)
            percentNatronOre = math.ceil(((math.ceil((massNatronOre*1000) - 0.5)/(ContainerMaxVol(data[k].maxHp)))*100))
            statusNatronOre = Status(percentNatronOre)
            maxVolNatronOre = (ContainerMaxVol(data[k].maxHp))/1000
        end
    end
    if massNatronOre == nil then
        massNatronOre = 0
        percentNatronOre = 0
        statusNatronOre = Error
        maxVolNatronOre = 0
    end

--T3 Stuff

    -- GarnieriteOre Variables 
    for k, v in pairs(data) do
        if string.match(data[k].Container, "Garnierite") then
            local weight = 2.60
            massGarnieriteOre = round(math.ceil((OptimizedContainerMass(data[k].ContainerMass) - ContainerSelfMass(data[k].maxHp)) / weight),1)
            percentGarnieriteOre = math.ceil(((math.ceil((massGarnieriteOre*1000) - 0.5)/(ContainerMaxVol(data[k].maxHp)))*100))
            statusGarnieriteOre = Status(percentGarnieriteOre)
            maxVolGarnieriteOre = (ContainerMaxVol(data[k].maxHp))/1000
        end
    end
    if massGarnieriteOre == nil then
        massGarnieriteOre = 0
        percentGarnieriteOre = 0
        statusGarnieriteOre = Error
        maxVolGarnieriteOre = 0
    end

    -- PetaliteOre Variables
    for k, v in pairs(data) do
        if string.match(data[k].Container, "Petalite") then
            local weight = 2.41
            massPetaliteOre = round(math.ceil((OptimizedContainerMass(data[k].ContainerMass) - ContainerSelfMass(data[k].maxHp)) / weight),1)
            percentPetaliteOre = math.ceil(((math.ceil((massPetaliteOre*1000) - 0.5)/(ContainerMaxVol(data[k].maxHp)))*100))
            statusPetaliteOre = Status(percentPetaliteOre)
            maxVolPetaliteOre = (ContainerMaxVol(data[k].maxHp))/1000
        end
    end
    if massPetaliteOre == nil then
        massPetaliteOre = 0
        percentPetaliteOre = 0
        statusPetaliteOre = Error
        maxVolPetaliteOre = 0
    end

    -- AcanthiteOre Variables
    for k, v in pairs(data) do
        if string.match(data[k].Container, "Acanthite") then
            local weight = 7.20
            massAcanthiteOre = round(math.ceil((OptimizedContainerMass(data[k].ContainerMass) - ContainerSelfMass(data[k].maxHp)) / weight),1)
            percentAcanthiteOre = math.ceil(((math.ceil((massAcanthiteOre*1000) - 0.5)/(ContainerMaxVol(data[k].maxHp)))*100))
            statusAcanthiteOre = Status(percentAcanthiteOre)
            maxVolAcanthiteOre = (ContainerMaxVol(data[k].maxHp))/1000
        end
    end
    if massAcanthiteOre == nil then
        massAcanthiteOre = 0
        percentAcanthiteOre = 0
        statusAcanthiteOre = Error
        maxVolAcanthiteOre = 0
    end

    -- PyriteOre Variables
    for k, v in pairs(data) do
        if string.match(data[k].Container, "Pyrite") then
            local weight = 5.01
            massPyriteOre = round(math.ceil((OptimizedContainerMass(data[k].ContainerMass) - ContainerSelfMass(data[k].maxHp)) / weight),1)
            percentPyriteOre = math.ceil(((math.ceil((massPyriteOre*1000) - 0.5)/(ContainerMaxVol(data[k].maxHp)))*100))
            statusPyriteOre = Status(percentPyriteOre)
            maxVolPyriteOre = (ContainerMaxVol(data[k].maxHp))/1000
        end
    end
    if massPyriteOre == nil then
        massPyriteOre = 0
        percentPyriteOre = 0
        statusPyriteOre = Error
        maxVolPyriteOre = 0
    end

--T4 Stuff

    -- CobaltiteOre Variables 
    for k, v in pairs(data) do
        if string.match(data[k].Container, "Cobaltite") then
            local weight = 6.33
            massCobaltiteOre = round(math.ceil((OptimizedContainerMass(data[k].ContainerMass) - ContainerSelfMass(data[k].maxHp)) / weight),1)
            percentCobaltiteOre = math.ceil(((math.ceil((massCobaltiteOre*1000) - 0.5)/(ContainerMaxVol(data[k].maxHp)))*100))
            statusCobaltiteOre = Status(percentCobaltiteOre)
            maxVolCobaltiteOre = (ContainerMaxVol(data[k].maxHp))/1000
        end
    end
    if massCobaltiteOre == nil then
        massCobaltiteOre = 0
        percentCobaltiteOre = 0
        statusCobaltiteOre = Error
        maxVolCobaltiteOre = 0
    end

    -- CryoliteOre Variables
    for k, v in pairs(data) do
        if string.match(data[k].Container, "Cryolite") then
            local weight = 2.95
            massCryoliteOre = round(math.ceil((OptimizedContainerMass(data[k].ContainerMass) - ContainerSelfMass(data[k].maxHp)) / weight),1)
            percentCryoliteOre = math.ceil(((math.ceil((massCryoliteOre*1000) - 0.5)/(ContainerMaxVol(data[k].maxHp)))*100))
            statusCryoliteOre = Status(percentCryoliteOre)
            maxVolCryoliteOre = (ContainerMaxVol(data[k].maxHp))/1000
        end
    end
    if massCryoliteOre == nil then
        massCryoliteOre = 0
        percentCryoliteOre = 0
        statusCryoliteOre = Error
        maxVolCryoliteOre = 0
    end

    -- GoldOre Variables
    for k, v in pairs(data) do
        if string.match(data[k].Container, "Gold Ore") then
            local weight = 19.30
            massGoldOre = round(math.ceil((OptimizedContainerMass(data[k].ContainerMass) - ContainerSelfMass(data[k].maxHp)) / weight),1)
            percentGoldOre = math.ceil(((math.ceil((massGoldOre*1000) - 0.5)/(ContainerMaxVol(data[k].maxHp)))*100))
            statusGoldOre = Status(percentGoldOre)
            maxVolGoldOre = (ContainerMaxVol(data[k].maxHp))/1000
        end
    end
    if massGoldOre == nil then
        massGoldOre = 0
        percentGoldOre = 0
        statusGoldOre = Error
        maxVolGoldOre = 0
    end

    -- KolbeckiteOre Variables
    for k, v in pairs(data) do
        if string.match(data[k].Container, "Kolbeckite") then
            local weight = 2.37
            massKolbeckiteOre = round(math.ceil((OptimizedContainerMass(data[k].ContainerMass) - ContainerSelfMass(data[k].maxHp)) / weight),1)
            percentKolbeckiteOre = math.ceil(((math.ceil((massKolbeckiteOre*1000) - 0.5)/(ContainerMaxVol(data[k].maxHp)))*100))
            statusKolbeckiteOre = Status(percentKolbeckiteOre)
            maxVolKolbeckiteOre = (ContainerMaxVol(data[k].maxHp))/1000
        end
    end
    if massKolbeckiteOre == nil then
        massKolbeckiteOre = 0
        percentKolbeckiteOre = 0
        statusKolbeckiteOre = Error
        maxVolKolbeckiteOre = 0
    end

--T5 Stuff

    -- RhodoniteOre Variables 
    for k, v in pairs(data) do
        if string.match(data[k].Container, "Rhodonite") then
            local weight = 3.76
            massRhodoniteOre = round(math.ceil((OptimizedContainerMass(data[k].ContainerMass) - ContainerSelfMass(data[k].maxHp)) / weight),1)
            percentRhodoniteOre = math.ceil(((math.ceil((massRhodoniteOre*1000) - 0.5)/(ContainerMaxVol(data[k].maxHp)))*100))
            statusRhodoniteOre = Status(percentRhodoniteOre)
            maxVolRhodoniteOre = (ContainerMaxVol(data[k].maxHp))/1000
        end
    end
    if massRhodoniteOre == nil then
        massRhodoniteOre = 0
        percentRhodoniteOre = 0
        statusRhodoniteOre = Error
        maxVolRhodoniteOre = 0
    end

    -- ColumbiteOre Variables
    for k, v in pairs(data) do
        if string.match(data[k].Container, "Columbite") then
            local weight = 5.38
            massColumbiteOre = round(math.ceil((OptimizedContainerMass(data[k].ContainerMass) - ContainerSelfMass(data[k].maxHp)) / weight),1)
            percentColumbiteOre = math.ceil(((math.ceil((massColumbiteOre*1000) - 0.5)/(ContainerMaxVol(data[k].maxHp)))*100))
            statusColumbiteOre = Status(percentColumbiteOre)
            maxVolColombiteOre = (ContainerMaxVol(data[k].maxHp))/1000
        end
    end
    if massColumbiteOre == nil then
        massColumbiteOre = 0
        percentColumbiteOre = 0
        statusColumbiteOre = Error
        maxVolColombiteOre = 0
    end

    -- IllmeniteOre Variables
    for k, v in pairs(data) do
        if string.match(data[k].Container, "Illmenite") then
            local weight = 4.55
            massIllmeniteOre = round(math.ceil((OptimizedContainerMass(data[k].ContainerMass) - ContainerSelfMass(data[k].maxHp)) / weight),1)
            percentIllmeniteOre = math.ceil(((math.ceil((massIllmeniteOre*1000) - 0.5)/(ContainerMaxVol(data[k].maxHp)))*100))
            statusIllmeniteOre = Status(percentIllmeniteOre)
            maxVolIllmeniteOre = (ContainerMaxVol(data[k].maxHp))/1000
        end
    end
    if massIllmeniteOre == nil then
        massIllmeniteOre = 0
        percentIllmeniteOre = 0
        statusIllmeniteOre = Error
        maxVolIllmeniteOre = 0
    end

    -- VanadiniteOre Variables
    for k, v in pairs(data) do
        if string.match(data[k].Container, "Vanadinite") then
            local weight = 6.95
            massVanadiniteOre = round(math.ceil((OptimizedContainerMass(data[k].ContainerMass) - ContainerSelfMass(data[k].maxHp)) / weight),1)
            percentVanadiniteOre = math.ceil(((math.ceil((massVanadiniteOre*1000) - 0.5)/(ContainerMaxVol(data[k].maxHp)))*100))
            statusVanadiniteOre = Status(percentVanadiniteOre)
            maxVolVanadiniteOre = (ContainerMaxVol(data[k].maxHp))/1000
        end
    end
    if massVanadiniteOre == nil then
        massVanadiniteOre = 0
        percentVanadiniteOre = 0
        statusVanadiniteOre = Error
        maxVolVanadiniteOre = 0
    end

    d1 = [[
            <head>
                <style>
                    .bar{
                        text-align: left;
                        vertical-align: top;
                        border-radius: 0 3px 3px 0;
                        }
                    }
                </style>
            </head>
            <div class="bootstrap">
            <h1 style="font-size: 6em;">]]
    t1 = [[</h1>
        <table style="
            text-transform: capitalize;
            font-size: 3em;
            table-layout: auto;
            width: 100%;
        ">
        </br>
        <tr style="
            width:100%;
            background-color: blue;
            color: white;
        ">
            <th>Type</th>
            <th>Qty</th>
            <th>MaxQty</th>
            <th>Levels</th>
            <th>Status</th>
        </tr>
        ]]
    c1 = [[
            </table>
            </div>
         ]]

    if displayT1 then
        html = d1..[[T1 Basic Status]]..t1..
            [[<tr>
                <th>Bauxite</th>
                <th>]]..massBauxiteOre..[[KL]]..[[</th>
                <th>]]..maxVolBauxiteOre ..[[KL]]..[[</th>
                ]]..BarGraph(percentBauxiteOre)..[[%
                ]]..statusBauxiteOre..[[
            </tr>
            <tr>
                <th>Coal</th>
                <th>]]..massCoalOre..[[KL]]..[[</th>
                <th>]]..maxVolCoalOre ..[[KL]]..[[</th>
                ]]..BarGraph(percentCoalOre)..[[%
                ]]..statusCoalOre..[[
            </tr>
            <tr>
                <th>Hematite</th>
                <th>]]..massHematiteOre..[[KL]]..[[</th>
                <th>]]..maxVolHematiteOre ..[[KL]]..[[</th>
                ]]..BarGraph(percentHematiteOre)..[[%
                ]]..statusHematiteOre..[[
            </tr>
            <tr>
                <th>Quartz</th>
                <th>]]..massQuartzOre..[[KL]]..[[</th>
                <th>]]..maxVolQuartzOre ..[[KL]]..[[</th>
                ]]..BarGraph(percentQuartzOre)..[[%
                ]]..statusQuartzOre..
                c1
        displayT1.setHTML(html)
    end

    if displayT2 then
        html = d1..[[T2 Uncommon Status]]..t1..
            [[<tr>
                <th>Natron</th>
                <th>]]..massNatronOre..[[KL]]..[[</th>
                <th>]]..maxVolNatronOre ..[[KL]]..[[</th>
                ]]..BarGraph(percentNatronOre)..[[%
                ]]..statusNatronOre..[[
            </tr>
            <tr>
                <th>Malachite</th>
                <th>]]..massMalachiteOre..[[KL]]..[[</th>
                <th>]]..maxVolMalachiteOre ..[[KL]]..[[</th>
                ]]..BarGraph(percentMalachiteOre)..[[%
                ]]..statusMalachiteOre..[[
            </tr>
            <tr>
                <th>Limestone</th>
                <th>]]..massLimestoneOre..[[KL]]..[[</th>
                <th>]]..maxVolLimestoneOre ..[[KL]]..[[</th>
                ]]..BarGraph(percentLimestoneOre)..[[%
                ]]..statusLimestoneOre..[[
            </tr>
            <tr>
                <th>Chromite</th>
                <th>]]..massChromiteOre..[[KL]]..[[</th>
                <th>]]..maxVolChromiteOre ..[[KL]]..[[</th>
                ]]..BarGraph(percentChromiteOre)..[[%
                ]]..statusChromiteOre..
                c1
        displayT2.setHTML(html)
    end

    if displayT3 then
        html = d1..[[T3 Advanced Status]]..t1..
            [[<tr>
                <th>Petalite</th>
                <th>]]..massPetaliteOre..[[KL]]..[[</th>
                <th>]]..maxVolPetaliteOre ..[[KL]]..[[</th>
                ]]..BarGraph(percentPetaliteOre)..[[%
                ]]..statusPetaliteOre..[[
            </tr>
            <tr>
                <th>Garnierite</th>
                <th>]]..massGarnieriteOre..[[KL]]..[[</th>
                <th>]]..maxVolGarnieriteOre ..[[KL]]..[[</th>
                ]]..BarGraph(percentGarnieriteOre)..[[%
                ]]..statusGarnieriteOre..[[
            </tr>
            <tr>
                <th>Pyrite</th>
                <th>]]..massPyriteOre..[[KL]]..[[</th>
                <th>]]..maxVolPyriteOre ..[[KL]]..[[</th>
                ]]..BarGraph(percentPyriteOre)..[[%
                ]]..statusPyriteOre..[[
            </tr>
            <tr>
                <th>Acanthite</th>
                <th>]]..massAcanthiteOre..[[KL]]..[[</th>
                <th>]]..maxVolAcanthiteOre ..[[KL]]..[[</th>
                ]]..BarGraph(percentAcanthiteOre)..[[%
                ]]..statusAcanthiteOre..
                c1
        displayT3.setHTML(html)
    end

    if displayT4 then
        html = d1..[[T4 Rare Status]]..t1..
            [[<tr>
                <th>Cobaltite</th>
                <th>]]..massCobaltiteOre..[[KL]]..[[</th>
                <th>]]..maxVolCobaltiteOre ..[[KL]]..[[</th>
                ]]..BarGraph(percentCobaltiteOre)..[[%
                ]]..statusCobaltiteOre..[[
            </tr>
            <tr>
                <th>Cryolite</th>
                <th>]]..massCryoliteOre..[[KL]]..[[</th>
                <th>]]..maxVolCryoliteOre ..[[KL]]..[[</th>
                ]]..BarGraph(percentCryoliteOre)..[[%
                ]]..statusCryoliteOre..[[
            </tr>
            <tr>
                <th>Gold Nuggets</th>
                <th>]]..massGoldOre..[[KL]]..[[</th>
                <th>]]..maxVolGoldOre ..[[KL]]..[[</th>
                ]]..BarGraph(percentGoldOre)..[[%
                ]]..statusGoldOre..[[
            </tr>
            <tr>
                <th>Kolbeckite</th>
                <th>]]..massKolbeckiteOre..[[KL]]..[[</th>
                <th>]]..maxVolKolbeckiteOre ..[[KL]]..[[</th>
                ]]..BarGraph(percentKolbeckiteOre)..[[%
                ]]..statusKolbeckiteOre..
                c1
        displayT4.setHTML(html)
    end

    if displayT5 then
        html = d1..[[T5 Exotic Status]]..t1..
            [[<tr>
                <th>Rhodonite</th>
                <th>]]..massRhodoniteOre..[[KL]]..[[</th>
                <th>]]..maxVolRhodoniteOre ..[[KL]]..[[</th>
                ]]..BarGraph(percentRhodoniteOre)..[[%
                ]]..statusRhodoniteOre..[[
            </tr>
            <tr>
                <th>Columbite</th>
                <th>]]..massColumbiteOre..[[KL]]..[[</th>
                <th>]]..maxVolColombiteOre ..[[KL]]..[[</th>
                ]]..BarGraph(percentColumbiteOre)..[[%
                ]]..statusColumbiteOre..[[
            </tr>
            <tr>
                <th>Illmenite</th>
                <th>]]..massIllmeniteOre..[[KL]]..[[</th>
                <th>]]..maxVolIllmeniteOre ..[[KL]]..[[</th>
                ]]..BarGraph(percentIllmeniteOre)..[[%
                ]]..statusIllmeniteOre..[[
            </tr>
            <tr>
                <th>Vanadinite</th>
                <th>]]..massVanadiniteOre..[[KL]]..[[</th>
                <th>]]..maxVolVanadiniteOre ..[[KL]]..[[</th>
                ]]..BarGraph(percentVanadiniteOre)..[[%
                ]]..statusVanadiniteOre..
                c1
        displayT5.setHTML(html)
    end
end
unit.setTimer('updateTable', 1)