classdef testAppUpdnModel < matlab.uitest.TestCase
    % testAppUpdnModel: Unit Test Suite.
    %   Failure means something is wrong with App    
    properties
        App
    end
    
    methods (TestMethodSetup)
        function launchApp(testCase)
            import matlab.unittest.diagnostics.ScreenshotDiagnostic 
            testCase.onFailure(ScreenshotDiagnostic);
            testCase.App = covid19nlsigApp;
            testCase.addTeardown(@delete,testCase.App);
        end
    end
    
    methods (Test)
        function test_MVersion(testCase)
            status = verLessThan('matlab', '9.7'); % 9.7 = R2019b
            testCase.assertFalse(status,...
                'NLSIG-COVID19Lab requires Matlab R2019b or later');
        end
        
        function test_UpdButton(testCase)          
            % press and verify update button
            testCase.press(testCase.App.UpdateDatabaseButton)
            testCase.verifyEqual(testCase.App.dataupdated,1);
        end
        
        function test_ModelButton(testCase)
            % choose and verify country-code
            testCase.verifyEqual(testCase.App.SearchCodesDropDown.Value,'WD')
            testCase.choose(testCase.App.SearchCodesDropDown,'US')
            testCase.verifyEqual(testCase.App.SearchCodesDropDown.Value,'US')
            testCase.choose(testCase.App.SearchCodesDropDown,'GB')
            testCase.verifyEqual(testCase.App.SearchCodesDropDown.Value,'GB')
            
            % choose epidemic type
            testCase.choose(testCase.App.DeathsButton)
            testCase.verifyTrue(testCase.App.DeathsButton.Value)
            %            
            testCase.choose(testCase.App.InfectionsButton)
            testCase.verifyTrue(testCase.App.InfectionsButton.Value)
            
            % type/pick a stop-date
            testCase.type(testCase.App.StopDateDatePicker,datetime(2020,09,01))
            testCase.verifyEqual(testCase.App.StopDateDatePicker.Value,datetime(2020,05,01))          
            
            % press and verify model button
            testCase.press(testCase.App.ModelButton)
            testCase.verifyEqual(testCase.App.modelran,1);
        end
        
    end
end