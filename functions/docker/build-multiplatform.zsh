#!/usr/bin/env zsh

function build-multiplatform() {

  # Multi-platform Docker Image Builder
  # This script builds and pushes images for both ARM64 and AMD64

  setopt LOCAL_OPTIONS
  set -e

  echo "🏗️  Multi-Platform Docker Image Builder"
  echo "========================================"
  echo ""

  # Colors
  local RED='\033[0;31m'
  local GREEN='\033[0;32m'
  local YELLOW='\033[1;33m'
  local BLUE='\033[0;34m'
  local NC='\033[0m'

  # Check if buildx is available
  if ! docker buildx version &> /dev/null; then
      echo -e "${RED}❌ Docker buildx is not available${NC}"
      echo "Please update Docker to a version that supports buildx"
      return 1
  fi

  echo -e "${GREEN}✅ Docker buildx is available${NC}"

  # Parse command line arguments
  local DOCKERFILE="Dockerfile"
  local BUILD_CONTEXT="."
  local BUILD_ARGS=""

  while [[ $# -gt 0 ]]; do
      case $1 in
          -f|--file)
              DOCKERFILE="$2"
              shift 2
              ;;
          -c|--context)
              BUILD_CONTEXT="$2"
              shift 2
              ;;
          --build-arg)
              BUILD_ARGS="$BUILD_ARGS --build-arg $2"
              shift 2
              ;;
          *)
              shift
              ;;
      esac
  done

  # Get image name - try package.json first, then directory name
  local IMAGE_NAME=""
  
  # Try to extract from package.json
  if [[ -f "package.json" ]]; then
      IMAGE_NAME=$(grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' package.json 2>/dev/null | sed 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
      if [[ -n "$IMAGE_NAME" ]]; then
          echo -e "${GREEN}📦 Found image name in package.json: ${IMAGE_NAME}${NC}"
      fi
  fi
  
  # Fallback to directory name if package.json doesn't exist or doesn't have a name
  if [[ -z "$IMAGE_NAME" ]]; then
      IMAGE_NAME=$(basename "$(pwd)")
      echo -e "${BLUE}📁 Using directory name as image name: ${IMAGE_NAME}${NC}"
  fi
  
  # Validate image name
  if [[ -z "$IMAGE_NAME" ]]; then
      echo -e "${RED}❌ Could not determine image name${NC}"
      return 1
  fi
  
  # Allow manual override
  echo ""
  echo -n "Image name detected as '${IMAGE_NAME}'. Press Enter to use this, or type a different name: "
  read USER_IMAGE_NAME
  if [[ -n "$USER_IMAGE_NAME" ]]; then
      IMAGE_NAME="$USER_IMAGE_NAME"
      echo -e "${YELLOW}✏️  Using custom image name: ${IMAGE_NAME}${NC}"
  fi

  echo -n "Enter registry URL (default: registry.builtbychristiaan.com): "
  read REGISTRY_URL
  REGISTRY_URL=${REGISTRY_URL:-registry.builtbychristiaan.com}

  echo -n "Enter tag (default: latest): "
  read TAG
  TAG=${TAG:-latest}

  echo -n "Add additional tags? (e.g., v1.0.0, comma-separated, or press Enter to skip): "
  read ADDITIONAL_TAGS

  local FULL_IMAGE="${REGISTRY_URL}/${IMAGE_NAME}:${TAG}"
  local TAG_ARGS="--tag ${FULL_IMAGE}"

  # Add additional tags if provided
  if [[ -n "$ADDITIONAL_TAGS" ]]; then
      local -a TAGS
      IFS=',' read -rA TAGS <<< "$ADDITIONAL_TAGS"
      for t in "${TAGS[@]}"; do
          t=$(echo "$t" | xargs)  # trim whitespace
          TAG_ARGS="$TAG_ARGS --tag ${REGISTRY_URL}/${IMAGE_NAME}:${t}"
      done
  fi

  echo ""
  echo "📋 Build Configuration:"
  echo "======================="
  echo "Image: ${FULL_IMAGE}"
  if [[ -n "$ADDITIONAL_TAGS" ]]; then
      echo "Additional tags: ${ADDITIONAL_TAGS}"
  fi
  echo "Platforms: linux/amd64, linux/arm64"
  echo "Dockerfile: ${DOCKERFILE}"
  echo "Build context: ${BUILD_CONTEXT}"
  if [[ -n "$BUILD_ARGS" ]]; then
      echo "Build args: ${BUILD_ARGS}"
  fi
  echo ""

  # Check if Dockerfile exists
  if [[ ! -f "$DOCKERFILE" ]]; then
      echo -e "${RED}❌ Dockerfile not found: ${DOCKERFILE}${NC}"
      return 1
  fi

  # Check if logged into registry
  echo "🔐 Checking registry authentication..."
  if ! docker login "${REGISTRY_URL}" 2>/dev/null; then
      echo -e "${YELLOW}⚠️  Not logged in to ${REGISTRY_URL}${NC}"
      echo "Please login to your registry:"
      docker login "${REGISTRY_URL}"
  fi

  echo -e "${GREEN}✅ Authenticated with registry${NC}"

  # Create buildx builder if it doesn't exist
  echo ""
  echo "🔧 Setting up buildx builder..."
  if ! docker buildx inspect multiplatform-builder &> /dev/null; then
      docker buildx create --name multiplatform-builder --driver docker-container --use
      echo -e "${GREEN}✅ Created multiplatform-builder${NC}"
  else
      docker buildx use multiplatform-builder
      echo -e "${GREEN}✅ Using existing multiplatform-builder${NC}"
  fi

  # Bootstrap the builder
  docker buildx inspect --bootstrap

  echo ""
  echo -n "Ready to build and push? (y/n): "
  read CONFIRM

  if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
      echo "Build cancelled"
      return 0
  fi

  echo ""
  echo "🚀 Building multi-platform image..."
  echo -e "${BLUE}This may take a while...${NC}"
  echo ""

  # Build and push
  echo "Executing: docker buildx build --platform linux/amd64,linux/arm64 ${TAG_ARGS} ${BUILD_ARGS} --file ${DOCKERFILE} --push --progress=plain ${BUILD_CONTEXT}"
  
  if docker buildx build \
      --platform linux/amd64,linux/arm64 \
      ${=TAG_ARGS} \
      ${=BUILD_ARGS} \
      --file "${DOCKERFILE}" \
      --push \
      --progress=plain \
      "${BUILD_CONTEXT}"; then
      echo ""
      echo -e "${GREEN}✅ Multi-platform image built and pushed successfully!${NC}"
      echo ""
      echo "📊 Image details:"
      echo "   ${FULL_IMAGE}"
      if [[ -n "$ADDITIONAL_TAGS" ]]; then
          local tag
          for tag in ${(s:,:)ADDITIONAL_TAGS}; do
              tag=${tag## } # trim leading spaces
              tag=${tag%% } # trim trailing spaces
              echo "   ${REGISTRY_URL}/${IMAGE_NAME}:${tag}"
          done
      fi
      echo ""
      echo "🔍 Verify platforms:"
      echo "   docker manifest inspect ${FULL_IMAGE}"
      echo ""
      echo "📥 Pull on any platform:"
      echo "   docker pull ${FULL_IMAGE}"
  else
      echo ""
      echo -e "${RED}❌ Build failed${NC}"
      return 1
  fi
}
