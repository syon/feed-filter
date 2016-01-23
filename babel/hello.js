
var Comment = React.createClass({
  render: function() {
    var data = this.props.feed;
    var mute = data.filter_rules.mute;
    return (
      <div className="feed panel panel-default">
        <div className="panel-heading">
          <h3 className="panel-title">
            {data.feed_id}
          </h3>
          <a href={"/view/" + data.feed_id} className="btn btn-default btn-sm">
            <i className="fa fa-chevron-right"></i>
            詳細
          </a>
        </div>
        <div className="panel-body">
          <table className="table no-border"><tbody>
            <tr>
              <th>フィードリンク</th>
              <td>
                <a href={"/view/" + data.feed_id}>
                  {"/feed/" + data.feed_id}
                </a>
              </td>
            </tr>
            <tr>
              <th>ソースフィード</th>
              <td>
                {data.feed_url}
              </td>
            </tr>
            <tr>
              <th>ミュート（タイトル）</th>
              <td>
                {_.map(mute.title, function(d, i){
                  return <span key={i} className="label label-default">{d}</span>
                })}
              </td>
            </tr>
            <tr>
              <th>ミュート（ドメイン）</th>
              <td>
              {_.map(mute.domain, function(d, i){
                  return <span key={i} className="label label-default">{d}</span>
                })}
              </td>
            </tr>
            <tr>
              <th>ミュート（開始URL）</th>
              <td>
              {_.map(mute.url_prefix, function(d, i){
                  return <span key={i} className="label label-default">{d}</span>
                })}
              </td>
            </tr>
          </tbody></table>
        </div>
      </div>
    );
  }
});

var CommentBox = React.createClass({
  loadCommentsFromServer: function() {
    $.ajax({
      url: this.props.url,
      dataType: 'json',
      cache: false,
      success: function(data) {
        // console.dir(data);
        this.setState({data: data});
      }.bind(this),
      error: function(xhr, status, err) {
        console.error(this.props.url, status, err.toString());
      }.bind(this)
    });
  },
  getInitialState: function() {
    return {data: []};
  },
  componentDidMount: function() {
    this.loadCommentsFromServer();
  },
  render: function() {
    return (
      <div className="commentBox">
        <CommentList data={this.state.data} />
      </div>
    );
  }
});

var CommentList = React.createClass({
  render: function() {
    var commentNodes = this.props.data.map(function (feed) {
      return (
        <Comment feed={feed} key={feed.feed_id} />
      );
    });
    if (commentNodes.length == 0) {
      return (<div></div>);
    }
    return (
      <div>
        <p className="text-center" style={{color: '#999'}}>
          ここから下は最近あなたが作成・更新したフィルタです。ブラウザのCookieに記録されています。
        </p>
        <hr />
        <div className="commentList">
          {commentNodes}
        </div>
      </div>
    );
  }
});

ReactDOM.render(
  <CommentBox url="/recent" />,
  document.getElementById('feedbox')
);
