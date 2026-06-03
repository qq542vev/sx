Describe 'sx_fn_is_valid'
	Include ./sx.sh

	It 'returns 0 for valid definitions'
		When call sx_fn_is_valid "f=:" "g=echo hello"
		The status should be success
	End

	It 'returns 0 for empty function body'
		When call sx_fn_is_valid "f="
		The status should be success
	End

	It 'returns 0 for complex function body'
		When call sx_fn_is_valid "f={ echo a | cat; } > /dev/null"
		The status should be success
	End

	It 'returns 1 for invalid names'
		When call sx_fn_is_valid "123f=:"
		The status should be failure
	End

	It 'returns 1 for missing equals sign'
		When call sx_fn_is_valid "invalid"
		The status should be failure
	End

	It 'returns 1 for syntax errors in the body'
		# "if" without "fi" is a syntax error
		When call sx_fn_is_valid "bad=if :"
		The status should be failure
	End

	It 'returns 1 if any of the definitions is invalid'
		When call sx_fn_is_valid "f=:" "123g=:"
		The status should be failure
	End

	It 'does not define the function globally'
		sx_fn_is_valid "should_not_exist=echo exist"
		When call should_not_exist
		The status should equal 127
		The stderr should include "should_not_exist"
	End
End
