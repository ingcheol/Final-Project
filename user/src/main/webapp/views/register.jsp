<%--
  Created by IntelliJ IDEA.
  User: 건
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script>
    const user_add = {
        init:function(){
            $('#user_add_btn').click(()=>{
                this.send();
            });
        },
        send:function(){
            $('#user_add_form').attr('method','post');
            $('#user_add_form').attr('action','<c:url value="/user/addimpl"/>');
            $('#user_add_form').submit();
        }
    }
    $(function(){
        user_add.init();
    });
</script>

<div class="col-sm-9">
    <h2>Register Page</h2>
    <form action="/user/addimpl" method="post">
        <div class="form-group">
            <label for="id">Id:</label>
            <input type="text" class="form-control" placeholder="Enter id" id="id" name="userId">
        </div>
        <div class="form-group">
            <label for="pwd">Password:</label>
            <input type="password" class="form-control" placeholder="Enter password" id="pwd" name="userPwd">
        </div>
        <div class="form-group">
            <label for="name">Name:</label>
            <input type="text" class="form-control" placeholder="Enter name" id="name" name="userName">
        </div>
        <div class="form-group">
            <label for="addr">Addr:</label>
            <input type="text" class="form-control" placeholder="Enter addr" id="addr" name="userAddr">
        </div>
        <button type="submit" class="btn btn-primary">Register</button>
    </form>
</div>

