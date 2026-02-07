#!/bin/bash

echo "Fixing Result.success and Result.failure calls..."

# Fix Result.success to Success
find lib -name "*.dart" -type f -exec sed -i 's/Result\.success(/Success(/g' {} \;

# Fix Result.failure to ResultFailure  
find lib -name "*.dart" -type f -exec sed -i 's/Result\.failure(/ResultFailure(/g' {} \;

echo "Done! Fixed all Result calls."
