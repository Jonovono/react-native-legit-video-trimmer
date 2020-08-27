import * as React from 'react';
import { StyleSheet, View, Text, requireNativeComponent } from 'react-native';
import LegitVideoTrimmer from 'react-native-legit-video-trimmer';

const VideoTrimmerView = requireNativeComponent("VideoTrimmerView");

export default function App() {
  const [result, setResult] = React.useState<number | undefined>();

  React.useEffect(() => {
    LegitVideoTrimmer.multiply(3, 7).then(setResult);
  }, []);

  return (
    <View style={styles.container}>
      <VideoTrimmerView 
        style={styles.container}
        source={'video url'}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1, alignItems: "stretch"
  },
});
