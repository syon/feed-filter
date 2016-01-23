"use strict";

var Comment = React.createClass({
  displayName: "Comment",

  render: function render() {
    var data = this.props.feed;
    var mute = data.filter_rules.mute;
    return React.createElement(
      "div",
      { className: "feed panel panel-default" },
      React.createElement(
        "div",
        { className: "panel-heading" },
        React.createElement(
          "h3",
          { className: "panel-title" },
          data.feed_id
        ),
        React.createElement(
          "a",
          { href: "/view/" + data.feed_id, className: "btn btn-default btn-sm" },
          React.createElement("i", { className: "fa fa-chevron-right" }),
          "詳細"
        )
      ),
      React.createElement(
        "div",
        { className: "panel-body" },
        React.createElement(
          "table",
          { className: "table no-border" },
          React.createElement(
            "tbody",
            null,
            React.createElement(
              "tr",
              null,
              React.createElement(
                "th",
                null,
                "フィードリンク"
              ),
              React.createElement(
                "td",
                null,
                React.createElement(
                  "a",
                  { href: "/view/" + data.feed_id },
                  "/feed/" + data.feed_id
                )
              )
            ),
            React.createElement(
              "tr",
              null,
              React.createElement(
                "th",
                null,
                "ソースフィード"
              ),
              React.createElement(
                "td",
                null,
                data.feed_url
              )
            ),
            React.createElement(
              "tr",
              null,
              React.createElement(
                "th",
                null,
                "ミュート（タイトル）"
              ),
              React.createElement(
                "td",
                null,
                _.map(mute.title, function (d, i) {
                  return React.createElement(
                    "span",
                    { key: i, className: "label label-default" },
                    d
                  );
                })
              )
            ),
            React.createElement(
              "tr",
              null,
              React.createElement(
                "th",
                null,
                "ミュート（ドメイン）"
              ),
              React.createElement(
                "td",
                null,
                _.map(mute.domain, function (d, i) {
                  return React.createElement(
                    "span",
                    { key: i, className: "label label-default" },
                    d
                  );
                })
              )
            ),
            React.createElement(
              "tr",
              null,
              React.createElement(
                "th",
                null,
                "ミュート（開始URL）"
              ),
              React.createElement(
                "td",
                null,
                _.map(mute.url_prefix, function (d, i) {
                  return React.createElement(
                    "span",
                    { key: i, className: "label label-default" },
                    d
                  );
                })
              )
            )
          )
        )
      )
    );
  }
});

var CommentBox = React.createClass({
  displayName: "CommentBox",

  loadCommentsFromServer: function loadCommentsFromServer() {
    $.ajax({
      url: this.props.url,
      dataType: 'json',
      cache: false,
      success: function (data) {
        // console.dir(data);
        this.setState({ data: data });
      }.bind(this),
      error: function (xhr, status, err) {
        console.error(this.props.url, status, err.toString());
      }.bind(this)
    });
  },
  getInitialState: function getInitialState() {
    return { data: [] };
  },
  componentDidMount: function componentDidMount() {
    this.loadCommentsFromServer();
  },
  render: function render() {
    return React.createElement(
      "div",
      { className: "commentBox" },
      React.createElement(CommentList, { data: this.state.data })
    );
  }
});

var CommentList = React.createClass({
  displayName: "CommentList",

  render: function render() {
    var commentNodes = this.props.data.map(function (feed) {
      return React.createElement(Comment, { feed: feed, key: feed.feed_id });
    });
    if (commentNodes.length == 0) {
      return React.createElement("div", null);
    }
    return React.createElement(
      "div",
      null,
      React.createElement(
        "p",
        { className: "text-center", style: { color: '#999' } },
        "ここから下は最近あなたが作成・更新したフィルタです。ブラウザのCookieに記録されています。"
      ),
      React.createElement("hr", null),
      React.createElement(
        "div",
        { className: "commentList" },
        commentNodes
      )
    );
  }
});

ReactDOM.render(React.createElement(CommentBox, { url: "/recent" }), document.getElementById('feedbox'));