import * as React from 'react';
import { StyleSheet, View, Text, requireNativeComponent } from 'react-native';
import LegitVideoTrimmer from 'react-native-legit-video-trimmer';

const VideoTrimmerView = requireNativeComponent("VideoTrimmerView");

export default function App() {
  const [result, setResult] = React.useState<number | undefined>();

  React.useEffect(() => {
    LegitVideoTrimmer.multiply(3, 7).then(setResult);
  }, []);

  selectedTrim = e => {
    console.log("event onSelectedTrim", e.nativeEvent.startTime);
    console.log("event endTime", e.nativeEvent.endTime);
    console.log("event filePath", e.nativeEvent.filePath);
  }
  onCancel = e => {
    console.log("event onCancel");
  }

  return (
    <View style={styles.container}>
      <VideoTrimmerView 
        style={styles.container}
        source={'test_video.mov'}
        minDuration={2}
        maxDuration={20}
        mainColor={'#555555'}
        handleColor={'#FFFFFF'}
        positionBarColor={'#FFFFFF'}
        doneButtonBackgroundColor={'#555555'}
        onSelectedTrim={this.selectedTrim}
        onCancel={this.onCancel}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1, alignItems: "stretch"
  },
});
