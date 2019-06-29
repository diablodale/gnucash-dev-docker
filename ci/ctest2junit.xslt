<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" indent="yes" encoding="UTF-8" cdata-section-elements="system-out system-err failure"/>
<xsl:decimal-format decimal-separator="." grouping-separator=","/>

	<xsl:template match="/Site">
        <xsl:variable name="Name" select="@Name"/>
        <xsl:variable name="TotalTime" select="(Testing/EndTestTime - Testing/StartTestTime)"/>
        <!-- xsl:variable name="ISOStartTime" select="xs:dateTime('1970-01-01T00:00:00') + xs:dayTimeDuration(concat('PT', Testing/StartTestTime, 'S'))" -->
        <xsl:variable name="NumberOfTests" select="count(Testing/Test)"/>
        <xsl:variable name="NumberOfFailures" select="count(Testing/Test[@Status='failed'])"/>
        <xsl:variable name="NumberOfSkipped" select="count(Testing/Test[@Status='notrun'])"/>
        <xsl:variable name="Hostname"><xsl:value-of select="@Hostname"/></xsl:variable>
		<testsuite name="{$Name}"
                   tests="{$NumberOfTests}"
                   skipped="{$NumberOfSkipped}"
                   failures="{$NumberOfFailures}"
                   errors="0"
                   time="{$TotalTime}"
                   hostname="{$Hostname}">
            <xsl:variable name="StartTestTime"><xsl:value-of select="Testing/StartTestTime"/></xsl:variable>
            <xsl:variable name="EndTestTime"><xsl:value-of select="Testing/EndTestTime"/></xsl:variable>
            <xsl:variable name="StartDateTime"><xsl:value-of select="Testing/StartDateTime"/></xsl:variable>
            <xsl:variable name="EndDateTime"><xsl:value-of select="Testing/EndDateTime"/></xsl:variable>
			<xsl:variable name="BuildName"><xsl:value-of select="@BuildName"/></xsl:variable>
			<xsl:variable name="BuildStamp"><xsl:value-of select="@BuildStamp"/></xsl:variable>
			<xsl:variable name="Generator"><xsl:value-of select="@Generator"/></xsl:variable>
			<xsl:variable name="CompilerName"><xsl:value-of select="@CompilerName"/></xsl:variable>
            <xsl:variable name="CompilerVersion"><xsl:value-of select="@CompilerVersion"/></xsl:variable>
			<xsl:variable name="OSName"><xsl:value-of select="@OSName"/></xsl:variable>
			<xsl:variable name="OSRelease"><xsl:value-of select="@OSRelease"/></xsl:variable>
			<xsl:variable name="OSVersion"><xsl:value-of select="@OSVersion"/></xsl:variable>
			<xsl:variable name="OSPlatform"><xsl:value-of select="@OSPlatform"/></xsl:variable>
			<xsl:variable name="Is64Bits"><xsl:value-of select="@Is64Bits"/></xsl:variable>
			<xsl:variable name="VendorString"><xsl:value-of select="@VendorString"/></xsl:variable>
			<xsl:variable name="VendorID"><xsl:value-of select="@VendorID"/></xsl:variable>
			<xsl:variable name="FamilyID"><xsl:value-of select="@FamilyID"/></xsl:variable>
			<xsl:variable name="ModelID"><xsl:value-of select="@ModelID"/></xsl:variable>
			<xsl:variable name="ProcessorCacheSize"><xsl:value-of select="@ProcessorCacheSize"/></xsl:variable>
			<xsl:variable name="NumberOfLogicalCPU"><xsl:value-of select="@NumberOfLogicalCPU"/></xsl:variable>
			<xsl:variable name="NumberOfPhysicalCPU"><xsl:value-of select="@NumberOfPhysicalCPU"/></xsl:variable>
			<xsl:variable name="TotalVirtualMemory"><xsl:value-of select="@TotalVirtualMemory"/></xsl:variable>
			<xsl:variable name="TotalPhysicalMemory"><xsl:value-of select="@TotalPhysicalMemory"/></xsl:variable>
			<xsl:variable name="LogicalProcessorsPerPhysical"><xsl:value-of select="@LogicalProcessorsPerPhysical"/></xsl:variable>
			<xsl:variable name="ProcessorClockFrequency"><xsl:value-of select="@ProcessorClockFrequency"/></xsl:variable>
			<properties>
				<property name="StartTestTime" value="{$StartTestTime}" />
                <property name="EndTestTime" value="{$EndTestTime}" />
                <property name="StartDateTime" value="{$StartDateTime}" />
                <property name="EndDateTime" value="{$EndDateTime}" />
                <property name="BuildName" value="{$BuildName}" />
				<property name="BuildStamp" value="{$BuildStamp}" />
				<property name="Generator" value="{$Generator}" />
				<property name="CompilerName" value="{$CompilerName}" />
                <property name="CompilerVersion" value="{$CompilerVersion}" />
				<property name="OSName" value="{$OSName}" />
				<property name="OSRelease" value="{$OSRelease}" />
				<property name="OSVersion" value="{$OSVersion}" />
				<property name="OSPlatform" value="{$OSPlatform}" />
				<property name="Is64Bits" value="{$Is64Bits}" />
				<property name="VendorString" value="{$VendorString}" />
				<property name="VendorID" value="{$VendorID}" />
				<property name="FamilyID" value="{$FamilyID}" />
				<property name="ModelID" value="{$ModelID}" />
				<property name="ProcessorCacheSize" value="{$ProcessorCacheSize}" />
				<property name="NumberOfLogicalCPU" value="{$NumberOfLogicalCPU}" />
				<property name="NumberOfPhysicalCPU" value="{$NumberOfPhysicalCPU}" />
				<property name="TotalVirtualMemory" value="{$TotalVirtualMemory}" />
				<property name="TotalPhysicalMemory" value="{$TotalPhysicalMemory}" />
				<property name="LogicalProcessorsPerPhysical" value="{$LogicalProcessorsPerPhysical}" />
				<property name="ProcessorClockFrequency" value="{$ProcessorClockFrequency}" />
			</properties>
			<xsl:apply-templates select="Testing/Test"/>
		</testsuite>
	</xsl:template>

    <xsl:template match="Testing/Test">
        <xsl:variable name="TestCaseName"><xsl:value-of select= "Name"/></xsl:variable>
        <xsl:variable name="TestCaseClassName" select="translate(Path, '/.', '.')"/>
        <xsl:variable name="TestCaseDuration" select="Results/NamedMeasurement[@name='Execution Time']/Value"/>
        <xsl:variable name="TestCaseOutput" select="normalize-space(Results/Measurement/Value)"/>
        <xsl:variable name="TestFile" select="normalize-space(FullCommandLine)"/>
        <testcase name="{$TestCaseName}" classname="{$TestCaseClassName}" time="{$TestCaseDuration}" file="{$TestFile}">
            <xsl:choose>
                <xsl:when test="@Status = 'passed'"/>
                <xsl:when test="@Status = 'notrun'">
                    <skipped/>
                </xsl:when>
                <xsl:otherwise><!-- "@Status = 'failed'" -->
                    <xsl:variable name="TestCaseFailType" select="normalize-space(Results/NamedMeasurement[@name='Exit Code']/Value)"/>
                    <xsl:variable name="TestCaseFailMsg" select="normalize-space(Results/NamedMeasurement[@name='Exit Value']/Value)"/>
                    <failure type="{$TestCaseFailType}"
                             message="{$TestCaseFailMsg}">
                        <xsl:value-of select="$TestCaseOutput"/>
                    </failure>
                </xsl:otherwise>
            </xsl:choose>
            <system-out>
                <xsl:value-of select="$TestCaseOutput"/>
            </system-out>
        </testcase>
    </xsl:template>
</xsl:stylesheet>
