# JMeter Test Plan Generator
# Creates 4 test scenarios for REST API benchmark

Write-Host "======================================"
Write-Host "JMeter Test Plan Generator" -ForegroundColor Cyan
Write-Host "======================================"
Write-Host ""

$baseDir = "c:\Users\HP\Desktop\Benchmark de performances des Web Services REST\jmeter"
$scenariosDir = "$baseDir\scenarios"

# Create scenarios directory if not exists
if (-not (Test-Path $scenariosDir)) {
    New-Item -ItemType Directory -Path $scenariosDir | Out-Null
}

Write-Host "Creating JMeter test plans..." -ForegroundColor Yellow
Write-Host ""

# Scenario 1: READ-heavy.jmx
Write-Host "1. READ-heavy.jmx (90% reads, 10% writes)" -ForegroundColor Green
@"
<?xml version="1.0" encoding="UTF-8"?>
<jmeterTestPlan version="1.2" properties="5.0" jmeter="5.6.3">
  <hashTree>
    <TestPlan guiclass="TestPlanGui" testclass="TestPlan" testname="READ-Heavy Benchmark" enabled="true">
      <stringProp name="TestPlan.comments">Prof. LACHGAR - Read-heavy scenario (90% reads)</stringProp>
      <boolProp name="TestPlan.functional_mode">false</boolProp>
      <boolProp name="TestPlan.serialize_threadgroups">false</boolProp>
      <elementProp name="TestPlan.user_defined_variables" elementType="Arguments">
        <collectionProp name="Arguments.arguments">
          <elementProp name="HOST" elementType="Argument">
            <stringProp name="Argument.name">HOST</stringProp>
            <stringProp name="Argument.value">`${__P(HOST,localhost)}</stringProp>
          </elementProp>
          <elementProp name="PORT" elementType="Argument">
            <stringProp name="Argument.name">PORT</stringProp>
            <stringProp name="Argument.value">`${__P(PORT,8080)}</stringProp>
          </elementProp>
          <elementProp name="SERVICE" elementType="Argument">
            <stringProp name="Argument.name">SERVICE</stringProp>
            <stringProp name="Argument.value">`${__P(SERVICE,jersey)}</stringProp>
          </elementProp>
        </collectionProp>
      </elementProp>
    </TestPlan>
    <hashTree>
      <ThreadGroup guiclass="ThreadGroupGui" testclass="ThreadGroup" testname="Users" enabled="true">
        <stringProp name="ThreadGroup.num_threads">50</stringProp>
        <stringProp name="ThreadGroup.ramp_time">10</stringProp>
        <stringProp name="ThreadGroup.duration">300</stringProp>
        <boolProp name="ThreadGroup.scheduler">true</boolProp>
        <stringProp name="ThreadGroup.on_sample_error">continue</stringProp>
      </ThreadGroup>
      <hashTree>
        <HTTPSamplerProxy guiclass="HttpTestSampleGui" testclass="HTTPSamplerProxy" testname="GET Items List" enabled="true">
          <stringProp name="HTTPSampler.domain">`${HOST}</stringProp>
          <stringProp name="HTTPSampler.port">`${PORT}</stringProp>
          <stringProp name="HTTPSampler.path">/api/items</stringProp>
          <stringProp name="HTTPSampler.method">GET</stringProp>
          <elementProp name="HTTPsampler.Arguments" elementType="Arguments">
            <collectionProp name="Arguments.arguments">
              <elementProp name="page" elementType="HTTPArgument">
                <stringProp name="Argument.name">page</stringProp>
                <stringProp name="Argument.value">`${__Random(0,50)}</stringProp>
              </elementProp>
              <elementProp name="size" elementType="HTTPArgument">
                <stringProp name="Argument.name">size</stringProp>
                <stringProp name="Argument.value">20</stringProp>
              </elementProp>
            </collectionProp>
          </elementProp>
        </HTTPSamplerProxy>
        <hashTree>
          <ThroughputController guiclass="ThroughputControllerGui" testclass="ThroughputController" testname="50% Throughput">
            <intProp name="ThroughputController.style">1</intProp>
            <stringProp name="ThroughputController.perThread">false</stringProp>
            <floatProp name="ThroughputController.percentThroughput">50.0</floatProp>
          </ThroughputController>
        </hashTree>
      </hashTree>
    </hashTree>
  </hashTree>
</jmeterTestPlan>
"@ | Out-File -Encoding UTF8 -FilePath "$scenariosDir\READ-heavy.jmx"

Write-Host "   Created: READ-heavy.jmx" -ForegroundColor Gray
Write-Host ""

# Scenario 2: JOIN-filter.jmx
Write-Host "2. JOIN-filter.jmx (Test JOIN FETCH impact)" -ForegroundColor Green
@"
<?xml version="1.0" encoding="UTF-8"?>
<jmeterTestPlan version="1.2" properties="5.0" jmeter="5.6.3">
  <hashTree>
    <TestPlan guiclass="TestPlanGui" testclass="TestPlan" testname="JOIN FETCH Benchmark" enabled="true">
      <stringProp name="TestPlan.comments">Prof. LACHGAR - N+1 query test</stringProp>
    </TestPlan>
    <hashTree>
      <ThreadGroup guiclass="ThreadGroupGui" testclass="ThreadGroup" testname="Users" enabled="true">
        <stringProp name="ThreadGroup.num_threads">50</stringProp>
        <stringProp name="ThreadGroup.ramp_time">10</stringProp>
        <stringProp name="ThreadGroup.duration">300</stringProp>
        <boolProp name="ThreadGroup.scheduler">true</boolProp>
      </ThreadGroup>
      <hashTree>
        <CSVDataSet guiclass="TestBeanGUI" testclass="CSVDataSet" testname="Category IDs" enabled="true">
          <stringProp name="filename">../data/categories.csv</stringProp>
          <stringProp name="delimiter">,</stringProp>
          <boolProp name="recycle">true</boolProp>
          <stringProp name="variableNames">category_id,code,name</stringProp>
        </CSVDataSet>
      </hashTree>
    </hashTree>
  </hashTree>
</jmeterTestPlan>
"@ | Out-File -Encoding UTF8 -FilePath "$scenariosDir\JOIN-filter.jmx"

Write-Host "   Created: JOIN-filter.jmx" -ForegroundColor Gray
Write-Host ""

# Scenario 3: MIXED.jmx
Write-Host "3. MIXED.jmx (CRUD operations mix)" -ForegroundColor Green
@"
<?xml version="1.0" encoding="UTF-8"?>
<jmeterTestPlan version="1.2" properties="5.0" jmeter="5.6.3">
  <hashTree>
    <TestPlan guiclass="TestPlanGui" testclass="TestPlan" testname="MIXED CRUD Benchmark" enabled="true">
      <stringProp name="TestPlan.comments">Prof. LACHGAR - Mixed CRUD operations</stringProp>
    </TestPlan>
    <hashTree>
      <ThreadGroup guiclass="ThreadGroupGui" testclass="ThreadGroup" testname="Users" enabled="true">
        <stringProp name="ThreadGroup.num_threads">50</stringProp>
        <stringProp name="ThreadGroup.ramp_time">10</stringProp>
        <stringProp name="ThreadGroup.duration">300</stringProp>
        <boolProp name="ThreadGroup.scheduler">true</boolProp>
      </ThreadGroup>
    </hashTree>
  </hashTree>
</jmeterTestPlan>
"@ | Out-File -Encoding UTF8 -FilePath "$scenariosDir\MIXED.jmx"

Write-Host "   Created: MIXED.jmx" -ForegroundColor Gray
Write-Host ""

# Scenario 4: HEAVY-body.jmx
Write-Host "4. HEAVY-body.jmx (Large payload test)" -ForegroundColor Green
@"
<?xml version="1.0" encoding="UTF-8"?>
<jmeterTestPlan version="1.2" properties="5.0" jmeter="5.6.3">
  <hashTree>
    <TestPlan guiclass="TestPlanGui" testclass="TestPlan" testname="Heavy Payload Benchmark" enabled="true">
      <stringProp name="TestPlan.comments">Prof. LACHGAR - 5KB payload stress test</stringProp>
    </TestPlan>
    <hashTree>
      <ThreadGroup guiclass="ThreadGroupGui" testclass="ThreadGroup" testname="Users" enabled="true">
        <stringProp name="ThreadGroup.num_threads">50</stringProp>
        <stringProp name="ThreadGroup.ramp_time">10</stringProp>
        <stringProp name="ThreadGroup.duration">300</stringProp>
        <boolProp name="ThreadGroup.scheduler">true</boolProp>
      </ThreadGroup>
    </hashTree>
  </hashTree>
</jmeterTestPlan>
"@ | Out-File -Encoding UTF8 -FilePath "$scenariosDir\HEAVY-body.jmx"

Write-Host "   Created: HEAVY-body.jmx" -ForegroundColor Gray
Write-Host ""

Write-Host "======================================"
Write-Host "JMeter Plans Created Successfully!" -ForegroundColor Green
Write-Host "======================================"
Write-Host ""
Write-Host "Location: $scenariosDir" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Download JMeter 5.6+: https://jmeter.apache.org/download_jmeter.cgi"
Write-Host "2. Start services: docker-compose up -d"
Write-Host "3. Run test: jmeter -n -t scenarios/READ-heavy.jmx -l results.jtl"
Write-Host ""
Write-Host "Note: These are starter templates. Open in JMeter GUI to customize." -ForegroundColor Magenta
