#!bin/sh
echo "Register Op Begin"

function read_dir(){  
    for file in ` ls $1 `  
    do  
       if [ -d $1"/"$file ]  
       then
           read_dir $1"/"$file  
       else
           fileName=$1"/"$file  
           findWord $fileName $2 $3
       fi  
    done  
}  
function findWord(){
	
	file=$1
	if [ "${file##*.}"x = "cpp"x ] || [ "${file##*.}"x = "mm"x ];then
		cat $file | while read line
		do
			if [[ $line =~ $2 ]]; then
				result=`echo $line|awk -F $3 '{
					a="___";
					b="__();";
					sub(/^[[:blank:]]*/,"",$3);
					c="extern void ";
					print(c""a""$2"__"$3""b) >> "extern";
					print (a""$2"__"$3""b) >> "call"
				}'`
			fi
		done
	fi
}

SHELL_FOLDER=$(dirname $0)
# handle CPU
CPUFILE=$SHELL_FOLDER/source/backend/cpu/CPUOPRegister.hpp
echo "// This file is generated by Shell for ops register\nnamespace MNN {" > $CPUFILE
echo "Start Register CPU"
CPU=$SHELL_FOLDER/source/backend/cpu
CPU_KEY="REGISTER_CPU_OP_CREATOR"
CPU_SEP='[(,)]'
read_dir $CPU $CPU_KEY $CPU_SEP
cat extern >> $CPUFILE
rm extern
echo '\nvoid registerCPUOps() {' >> $CPUFILE
cat call >> $CPUFILE
echo '}\n}' >> $CPUFILE
rm call

# handle Shape
echo "Start Register Shape"
SHAPEFILE=$SHELL_FOLDER/source/shape/ShapeRegister.hpp
SHAPE=$SHELL_FOLDER/source/shape
SHAPE_KEY="REGISTER_SHAPE"
SHAPE_SEP='[(,)]'
echo "// This file is generated by Shell for ops register\nnamespace MNN {" > $SHAPEFILE
read_dir $SHAPE $SHAPE_KEY $SHAPE_SEP
cat extern >> $SHAPEFILE
rm extern
echo '\nvoid registerShapeOps() {' >> $SHAPEFILE
cat call >> $SHAPEFILE
echo '}\n}' >> $SHAPEFILE
rm call

#hanle Metal
METALFILE=$SHELL_FOLDER/source/backend/metal/MetalOPRegister.hpp
METAL=$SHELL_FOLDER/source/backend/metal
METAL_KEY="REGISTER_METAL_OP_CREATOR"
METAL_SEP='[(,)]'
echo "// This file is generated by Shell for ops register\nnamespace MNN {\n#ifdef MNN_BUILD_METAL" > $METALFILE
echo "Start Register Metal"
read_dir $METAL $METAL_KEY $METAL_SEP
cat extern >> $METALFILE
rm extern
echo '\nvoid registerMetalOps() {' >> $METALFILE
cat call >> $METALFILE
echo '}\n#endif\n}' >> $METALFILE
rm call

echo "Register Op End"