import React from "react";
const Loading = ({ loading }) => {
  if (!loading) {
    return <div></div>;
  }

  return (
    <div className="loading">
      <div className="loading-image">
        <img
        src="https://media.giphy.com/media/y1ZBcOGOOtlpC/giphy.gif"
        alt="golfgif"
        />
      </div>
    </div>
  );
};

export default Loading;
