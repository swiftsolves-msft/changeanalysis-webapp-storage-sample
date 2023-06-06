$(document).ready(function () {
    $('.lazy').Lazy({
        scrollDirection: 'vertical',
        effect: 'fadeOut',
        visibleOnly: true,
        onError: function (element) {
            console.log('error loading ' + element.data('src'));
        }
    });
});
