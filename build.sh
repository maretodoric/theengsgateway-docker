#!/bin/bash

IMAGENAME=theengsgateway
REPO=maretodoric
PLATFORMS=(
	linux/amd64
	linux/arm64
)

_help() {
	cat <<EOF
Usage $(basename $0) [-n] [-x [--false] [--platforms] [--clear [--all]]] [ -r <registry_name>] [-p <repo_name>] [-i <image_name>] [-h]

Docker build helper script

Options:
  -n, --non-interactive   Does not prompt for tag version, instead uses from VERSION variable in .env file
  -x, --buildx             Performs cross build, look for additional options for "Cross Build" below
  -r, --registry           Specify docker registry where to push images to, by default uses hub.docker.io
  -p, --repo               Name of repo where to store the image - default from env variable REPO
  -i, --image-name         Image name to save under, will be combined repo/image_name - default from env variable IMAGENAME
  -v, --version            Version tag to use, default uses VERSION variable from .env file, this will NOT update .env file
  -h, --help               Displays this help menu

Cross Build Options:
  --false                  Does not perform cross build if BUILDX variable is true in .env file
  --clear [--all]          Prunes previous build cache, if --all is specified, removes all unused images, not just dangling ones
  --platforms              Space-separated list of platforms to cross-build, example linux/amd64 linux/arm64  
EOF

exit $1
}

hasvalue() {
	if [[ $1 =~ ^- ]]; then
		return 1
	elif [ x"$1" == "x" ]; then
		return 1
	else
		return 0
	fi
}

valueerr(){
	echo "ERROR, $1 specified without value"
	exit 1
}

if [ -f .env ]; then
	. .env
else
	echo "ERROR. .env file does not exist in current directory. Must exist and contain at least VERSION, BUILDX, BUILDX_PURGE variables"
	exit 1
fi

until [ $# -eq 0 ]; do
	case $1 in
		"-n"|"--non-interactive") NON_INTERACTIVE=true ;;
		"-x"|"--buildx")
			if [[ $2 == --false ]]; then
				shift
				BUILDX=false
			else
				BUILDX=true
			fi

			if [[ $2 == --clear ]]; then
				shift
				BUILDX_PURGE=true
				if [[ $2 == --all ]]; then
					shift
					BUILDX_PURGE_PARAMS="--all"
				fi
			fi

			if [[ $2 == --platforms ]]; then
				PLATFORMS=()
				shift
				for i in $@; do
					if [[ $2 =~ ^- ]]; then
						break
					else
						PLATFORMS+=($2)
						shift
					fi
				done
				if [ ${#PLATFORMS} -eq 0 ]; then
					echo "ERROR, --platforms option applied but no platform specified"
					exit 1
				fi
			fi
		       	;;
		"-r"|"--registry")
			if hasvalue $2; then
				REGISTRY="$2"
				shift
			else
				valueerr $1
			fi
			;;
		"-p"|"--repo")
			if hasvalue $2; then
				REPO="$2"
				shift
			else
				valueerr $1
			fi
			;;
		"-i"|"--image-name")
			if hasvalue $2; then
				IMAGENAME="$2"
				shift
			else
				valueerr $1
			fi
			;;
		"-v"|"--version")
			if hasvalue $2; then
				NON_INTERACTIVE=true
				VERSION="$2"
				shift
			else
				valueerr $1
			fi
			;;
		"-h"|"--help") _help ;;
		*) echo "Unknown parameter: $1" > /dev/stderr; _help 1 ;;
	esac
	shift
done

# Make sure we don't ask for version in non-interactive mode
if [[ $NON_INTERACTIVE == true ]]; then
	_VERSION=$VERSION
else
	# Or ask if we are not in non-interactive
	read -p "Tag Version: " -ei $VERSION _VERSION
fi

# Make sure we update .env file with new version
if ! [[ $VERSION == $_VERSION ]]; then
	sed -i "s/^VERSION.*/VERSION=$_VERSION/" .env
	VERSION=$_VERSION
fi

if ! [ x"$REGISTRY" == "x" ]; then
	echo "Custom registry applied - $REGISTRY"
	REPO="${REGISTRY}/$REPO"
fi


cat <<EOF
Running script with following config options:

$(if $NON_INTERACTIVE; then echo -e "Non-Interactive: Enabled"; else echo "Non-Interactive: Disabled"; fi)
$(if $BUILDX; then echo -e "Cross-Build: Enabled\nPlatforms: ${PLATFORMS[@]}\nPurging Cache: $BUILDX_PURGE"; else echo -e "Cross-Build: Disabled"; fi)

Version: $VERSION
Repo: $REPO
Image Name: $IMAGENAME
Registry: ${REGISTRY:=Default}
Full Image Name: $REPO/$IMAGENAME-{arch}

Waiting 5 seconds before continuing, you can CTRL+C now to abort.
EOF

for i in {1..5}; do
	sleep 1
done

if [[ $BUILDX == true ]]; then
	if [[ $BUILDX_PURGE == true ]]; then
		echo "Clearing buildx cache..."
		docker buildx prune $BUILDX_PURGE_PARAMS -f
	fi

	for i in ${PLATFORMS[@]}; do
		arch=${i#*/}
		echo "Building for platform: $i ..."
		docker buildx build --push --platform $i -t $REPO/${IMAGENAME}-${arch}:$VERSION -t $REPO/${IMAGENAME}-${arch}:latest .
		echo "Updating readme..."
		cp README.md README-${arch}.md
		sed -i "s/ARCH/${arch}/g" README-${arch}.md
		docker pushrm -f README-${arch}.md $REPO/${IMAGENAME}-${arch}
		rm -rf README-${arch}.md
	done
	echo "Done!"
else
	arch=amd64
	docker build -t $REPO/$IMAGENAME-${arch}:$VERSION -t $REPO/$IMAGENAME-${arch}:latest .
	if [ $? -eq 0 ]; then
		echo "Build successful, pushing to $REPO/$IMAGENAME-${arch} ..."
		docker push $REPO/$IMAGENAME-${arch}:latest
		docker push $REPO/$IMAGENAME-${arch}:$VERSION
		echo "Updating readme..."
		cp README.md README-${arch}.md
		sed -i "s/ARCH/${arch}/g" README-${arch}.md
		docker pushrm -f README-${arch}.md $REPO/${IMAGENAME}-${arch}
		rm -rf README-${arch}.md
		echo "Done!"
	fi
fi

