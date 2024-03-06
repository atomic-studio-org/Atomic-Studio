export def user_prompt [yes: bool] {
  if $yes {
    return true 
  }
  let user_response = input "[Y/n]> "
  return (($user_response =~ "(?i)yes") or ($user_response =~ "(?i)y"))
}

export def fancy_prompt_message [package_manager: string] {
  echo $"($package_manager) is not installed. Do you wish to install it?"
}

