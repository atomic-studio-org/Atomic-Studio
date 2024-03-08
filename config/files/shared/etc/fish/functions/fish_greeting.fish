function fish_greeting
	if test -d "$HOME"
		if test -x "/usr/bin/studio"
			/usr/bin/studio motd
		end
	end

	if set -q fish_private_mode
		echo "fish is running in private mode, history will not be persisted."
	end
end
