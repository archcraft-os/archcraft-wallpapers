#!/usr/bin/env bash

## Copyright (C) 2020-2024 Aditya Shakya <adi1090x@gmail.com>

## Dirs
DIR="$(pwd)"
PKGS=(`ls -d */ | cut -f1 -d'/'`)
PKGDIR="$DIR/packages"

## Script Termination
exit_on_signal_SIGINT () {
    { printf "\n\n%s\n" "Script interrupted." 2>&1; echo; }
    exit 0
}

exit_on_signal_SIGTERM () {
    { printf "\n\n%s\n" "Script terminated." 2>&1; echo; }
    exit 0
}

trap exit_on_signal_SIGINT SIGINT
trap exit_on_signal_SIGTERM SIGTERM

## Build packages
build_pkgs () {
	local pkg

	if [[ ! -d "$PKGDIR" ]]; then
		mkdir -p "$PKGDIR"
	fi

	echo -e "\nBuilding Packages - \n"
	for pkg in "${PKGS[@]}"; do
		echo -e "Building ${pkg}..."
		cd ${pkg} && makepkg -sc
		mv *.pkg.tar.zst "$PKGDIR"

		# Verify
		while true; do
			set -- "$PKGDIR"/${pkg}-*
			if [[ -e "$1" ]]; then
				echo -e "\nPackage '${pkg}' generated successfully.\n"
				break
			else
				echo -e "\nFailed to build '${pkg}', Exiting...\n"
				exit 1;
			fi
		done
		cd "$DIR"
	done
	
	RDIR='../pkgs/x86_64'
	if [[ -d "$RDIR" ]]; then
		mv -f "$PKGDIR"/*.pkg.tar.zst "$RDIR" && rm -r "$PKGDIR"
		echo -e "Packages moved to Repository.\n[!] Don't forget to update the database.\n"
	fi
}

## Execute
build_pkgs
