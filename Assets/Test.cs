using UnityEngine;
using System.Collections;

public class Test : MonoBehaviour 
{
	[SerializeField]
	private LLT.EMRoot _root;
	
	// Use this for initialization
	IEnumerator Start ()
	{
		var rootObject = _root.DisplayTree.FindObject();
		yield return new WaitForSeconds(1f);
		
		rootObject.AnimationHead.GotoAndPlay("green");
		
		yield return new WaitForSeconds(1f);
		
		rootObject.AnimationHead.GotoAndPlay("blue");
		
		yield return new WaitForSeconds(1f);
		
		rootObject.AnimationHead.GotoAndPlay("red");
	}
}
