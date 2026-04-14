# Model Klasörü

Bu klasöre YOLOv8 ile eğitilen ve TFLite formatına dönüştürülen model yerleştirilecektir.

Beklenen dosya: `landmark_yolov8.tflite`

Dönüştürme komutu:
```
yolo export model=best.pt format=tflite imgsz=320
```
