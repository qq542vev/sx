Describe 'sx_fn_set'
	Include ./sx.sh

	It 'defines a function dynamically'
		sx_fn_set "my_func=echo hello"
		result=$(my_func)
		The value "$result" should equal "hello"
	End

	It 'defines multiple functions'
		sx_fn_set "f1=echo 1" "f2=echo 2"
		The value "$(f1)" should equal "1"
		The value "$(f2)" should equal "2"
	End

	It 'can use positional parameters in the defined function'
		sx_fn_set 'say=echo "Hello, $1"'
		The value "$(say World)" should equal "Hello, World"
	End

	It 'returns EX_USAGE (64) for invalid function names'
		When call sx_fn_set "1invalid=echo fail"
		The status should equal 64
	End

	It 'returns EX_USAGE (64) for missing equals sign'
		When call sx_fn_set "invalid_format"
		The status should equal 64
	End

	It 'returns EX_USAGE (64) for syntax errors in the body'
		# "if" without "fi" is a syntax error
		When call sx_fn_set "bad_fn=if :"
		The status should equal 64
	End

	It 'skips checks when SX_CFG_SKIP_CHK is 1'
		SX_CFG_SKIP_CHK=1 sx_fn_set "my_fast_fn=echo fast"
		The value "$(my_fast_fn)" should equal "fast"
	End
End
