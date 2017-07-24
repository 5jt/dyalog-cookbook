 load_ws;Load
⍝ This will recreate ws CLEAR WS as it was on 2017/7/20  8:57:29
 Load←{'**'≡2↑⍕s←⎕SE.SALT.Load ⍵:⎕←s} ⍝ used to verify SALT.Load's result

 #.(⎕IO ⎕ML ⎕WX ⎕CT ⎕PP)←1 1 3 1E¯14 15
 Load'"C:\T\TheDyalogCookbook\code\v11\MyHelp" -target=#'          ⍝ #.MyHelp

 ⎕WSID←'CLEAR WS'
 #⍎⎕LX←'#.MyApp.StartFromCmdLine #.MyApp.GetCommandLineArg ⍬'
