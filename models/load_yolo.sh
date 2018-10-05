REDIS_CLI=../deps/redis/src/redis-cli

GRAPH_FILE=tiny-yolo-voc.pb
INPUT_VAR=input
OUTPUT_VAR=output

GRAPH_KEY=yolo
INPUT_KEY=image
OUTPUT_KEY=output

IMAGE_FILE=../img/sample_dog_224.raw
IMAGE_WIDTH=224
IMAGE_HEIGHT=224

echo "SET GRAPH"
$REDIS_CLI -x TF.GRAPH $GRAPH_KEY < $GRAPH_FILE

# TODO: cast tensor, change shape of tensor (NHWC, NCHW)
#       instead of casting, we could specify the type of data provided in the blob
#       after the BLOB keyword
# Preprocess: resizes the $INPUT_KEY to cfg size, scales 0-255 to 0-1, and throws away alpha channel
# Not clear why TF doesn't complain when we feed a random $INPUT_KEY
$REDIS_CLI -x TF.TENSOR $INPUT_KEY FLOAT 4 1 $IMAGE_WIDTH $IMAGE_HEIGHT 3 BLOB < $IMAGE_FILE

echo "GET TENSORS"
# $REDIS_CLI --raw TF.DATA $INPUT_KEY

echo "RUN GRAPH"
$REDIS_CLI TF.RUN $GRAPH_KEY 1 $INPUT_KEY $INPUT_VAR $OUTPUT_KEY $OUTPUT_VAR
$REDIS_CLI TF.RUN $GRAPH_KEY 1 $INPUT_KEY $INPUT_VAR $OUTPUT_KEY $OUTPUT_VAR
$REDIS_CLI TF.RUN $GRAPH_KEY 1 $INPUT_KEY $INPUT_VAR $OUTPUT_KEY $OUTPUT_VAR
$REDIS_CLI TF.RUN $GRAPH_KEY 1 $INPUT_KEY $INPUT_VAR $OUTPUT_KEY $OUTPUT_VAR
$REDIS_CLI TF.RUN $GRAPH_KEY 1 $INPUT_KEY $INPUT_VAR $OUTPUT_KEY $OUTPUT_VAR
$REDIS_CLI TF.RUN $GRAPH_KEY 1 $INPUT_KEY $INPUT_VAR $OUTPUT_KEY $OUTPUT_VAR
$REDIS_CLI TF.RUN $GRAPH_KEY 1 $INPUT_KEY $INPUT_VAR $OUTPUT_KEY $OUTPUT_VAR
$REDIS_CLI TF.RUN $GRAPH_KEY 1 $INPUT_KEY $INPUT_VAR $OUTPUT_KEY $OUTPUT_VAR
$REDIS_CLI TF.RUN $GRAPH_KEY 1 $INPUT_KEY $INPUT_VAR $OUTPUT_KEY $OUTPUT_VAR
$REDIS_CLI TF.RUN $GRAPH_KEY 1 $INPUT_KEY $INPUT_VAR $OUTPUT_KEY $OUTPUT_VAR
$REDIS_CLI TF.RUN $GRAPH_KEY 1 $INPUT_KEY $INPUT_VAR $OUTPUT_KEY $OUTPUT_VAR
$REDIS_CLI TF.RUN $GRAPH_KEY 1 $INPUT_KEY $INPUT_VAR $OUTPUT_KEY $OUTPUT_VAR
$REDIS_CLI TF.RUN $GRAPH_KEY 1 $INPUT_KEY $INPUT_VAR $OUTPUT_KEY $OUTPUT_VAR
$REDIS_CLI TF.RUN $GRAPH_KEY 1 $INPUT_KEY $INPUT_VAR $OUTPUT_KEY $OUTPUT_VAR

# TODO:
# it would be interesting to take the output of yolo and compute the rest directly,
# but we need TorchScript for that

#echo "GET TENSOR"
#$REDIS_CLI TF.VALUES $OUTPUT_KEY

#echo "GET TENSOR RAW"
#$REDIS_CLI --raw TF.DATA $OUTPUT_KEY

echo "NDIMS" `$REDIS_CLI TF.NDIMS $OUTPUT_KEY`
echo "DIMS" `$REDIS_CLI TF.DIMS $OUTPUT_KEY`
echo "TYPE" `$REDIS_CLI TF.TYPE $OUTPUT_KEY`
echo "SIZE" `$REDIS_CLI TF.SIZE $OUTPUT_KEY`

