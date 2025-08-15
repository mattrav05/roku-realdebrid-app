sub init()
    print "MainScene init"
    m.loginButton = m.top.findNode("loginButton")
    m.loginButton.observeField("buttonSelected", "onLoginPressed")
    m.loginButton.setFocus(true)
end sub

sub onLoginPressed()
    print "Login button pressed"
    ' TODO: Implement Real-Debrid authentication
end sub